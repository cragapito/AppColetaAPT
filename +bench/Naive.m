classdef Naive
    %Funções de cálculo "ingênuas" para propósito geral.
    %   Não devem ser herdadas ou sobreescritas
    %   E devem usar a API dos instrumentos

    properties
        dataTraces
    end

    % DUT - Device Under Test
    % DUM - Devices Under Mesure
    methods
        function dataTraces = getTracesFromUnit(instrumentObj, nTraces)
            % Função de referência, a ser incorporada na classe correta.
            % Faz chamadas de traço e acumula para entregar os dados

            %dataTraces = zeros(nTraces, height(ref), 'single');
            idx1 = find(strcmp(instrumentObj.App.receiverObj.Config.Tag, instrumentObj.conn.UserData.instrSelected.Tag), 1);
            DataPoints_Limits = instrumentObj.App.receiverObj.Config.DataPoints_Limits{idx1};

            if diff(round(DataPoints_Limits))
                % Datapoints = instrumentObj.getDataPoints;
                error('O instrumento deve ter um número fixo de pontos! A evoluir...')
            end
            DataPoints = DataPoints_Limits(1);

            instrumentObj.startUp()

            dataTraces = zeros(nTraces, DataPoints, 'single');
            for ii = 1:nTraces
                % % Mostra os passos dos traces.
                % if ~mod(ii,10); ii
                % end
                dataTraces(ii, :) = instrumentObj.getTrace(1);
            end

            % dataTraces = table( header, traceData, 'VariableNames', {'freq', 'value'});
        end

        function shape = calculateShape(dataTraces)
            nTraces = height(dataTraces);

            % o delta é sempre um número negativo para xdB.
            delta = -26;

            % Pré-aloca a tabela
            shape = zeros(nTraces, 2, 'single');

            for ii = 1:nTraces
                fInf = NaN;
                fSup = NaN;

                peak = max( dataTraces(ii,:) );
                peakIndex = find( dataTraces(ii,:) == peak );


                % calculateInternalShape (Do pico para as bordas)

                % Busca do pico para acima
                for jj = peakIndex+1:width(dataTraces(ii,:))
                    if dataTraces(ii,jj) <= peak + delta
                        % Interpola a frequência
                        fSup = interp1( dataTraces(ii,jj-1:jj), trace.freq(jj-1:jj), peak + delta);
                        break;
                    end
                end

                % Busca do pico para abaixo
                for jj = peakIndex-1:-1:1
                    if dataTraces(ii,jj) <= peak + delta
                        % Interpola a frequência
                        fInf = interp1( dataTraces(ii,jj:jj+1), trace.freq(jj:jj+1), peak + delta);
                        break;
                    end
                end
                shape(ii,:) = [fInf,fSup];
            end

            % TODO% Calcular de fora para dentro e comparar.

            % Remove qualquer linha com NaN
            indexNaN = any(isnan(shape),2);
            shape = shape(~indexNaN,:);
        end

        function calculateBW(dataTraces)
            shape = apt.fcn.naive.calculateShape(dataTraces);

            nTraces = height(shape);

            BW = diff(shape');

            stdBW = std(BW);

            fprintf('Naive: De %i medidas válidas, o desvio está em Max: %0.f, Min: %0.f, Avg: %0.f ± %0.f Hz\n', nTraces, max(BW), min(BW), mean(BW), std(BW));
            s68 = mean(BW) + stdBW;
            s89 = mean(BW) + 1.5 * stdBW;
            s95 = mean(BW) + 2 * stdBW;
            fprintf('Naive: Se a distribuição for normal, 68%% do desvio está abaixo de %.0f kHz.\n', s68 - stdBW);
            fprintf('Naive: Se a distribuição for normal, 89%% do desvio está abaixo de %.0f kHz.\n', s89 - stdBW);
            fprintf('Naive: Se a distribuição for normal, 95%% do desvio está abaixo de %.0f kHz.\n', s95 - stdBW);
        end

        function estimateCW(dataTraces)
            shape = apt.fcn.naive.calculateShape(dataTraces);

            % Freq. média dos valores
            eCW = mean(shape, 2);

            % Média e desvio do total
            avgECW = mean( eCW );
            stdECW = std ( eCW );

            % Calcula a distância de cada valor para a média
            zscore = [ abs( ( eCW - avgECW ) / stdECW ), (1:numel(eCW))' ];

            [~,zIdx] = sort(zscore(:,1));
            eCW = zscore(zIdx,:);
            eCW = eCW( 1:round(height(eCW) * 0.2), : );

            fprintf('Naive: Frequência central estimada para 68%% das medidas em %0.f ± %0.f Hz.\n', double(avgECW + eCW(1)), std(eCW(1,:)) );
            fprintf('Naive: Frequência central estimada para 89%% das medidas em %0.f ± %0.f Hz.\n', double(avgECW + eCW(1)), 1.5 * std(eCW(1,:)) );
            fprintf('Naive: Frequência central estimada para 95%% das medidas em %0.f ± %0.f Hz.\n', double(avgECW + eCW(1)), 2 * std(eCW(1,:)) );
        end
    end
end