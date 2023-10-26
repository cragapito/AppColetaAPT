% hReceiver, FreqList, OptionalArguments
function shape = calculateInternalShape(~,~,~)

    % calculateInternalShape
    % TODO: calculateExternalShape
    % Utilizando medidas do workspace do caderno de testes.
    load('C:\P&D\AppAPT\+Analysers\TestBook\TestTektronixSA2500.mat', 'trcs', 'trace');

    % trcs - Traces no workspace
    nTraces = height(trcs);

    delta = -26;

    % Conterá a frequência inferior e superior para um delta dB especificado.
    shape = zeros(nTraces, 2, 'single');
   
    for ii = 1:nTraces
        fInf = NaN;
        fSup = NaN;
        
        peak = max( trcs(ii,:) );
        peakIndex = find( trcs(ii,:) == peak );

        % Para cima
        for jj = peakIndex:width(trcs(ii,:))
            if trcs(ii,jj) <= peak + delta 
                fSup = trace.freq(jj);
                break;
            end
        end
    
        % Para baixo
        for jj = peakIndex:-1:1
            if trcs(ii,jj) <= peak + delta
                fInf = trace.freq(jj);
                break;
            end 
        end
        shape(ii,:) = [fInf,fSup];
    end
    
    % Remove qualquer linha com NaN
    indexNaN = any(isnan(shape),2); 
    shape = shape(~indexNaN,:);
end