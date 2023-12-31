classdef ANRITSU < Analysers.Analyser
    methods
        function obj = ANRITSU(~,args)
            obj.prop = args;
        end

        function scpiReset(obj)
            obj.sendCMD(":SYSTem:PRESET");
        end

        function startUp(obj)
            anl = tcpclient( obj.prop('ip'), double(obj.prop('port')) );
            writeline(anl, ['' ...
                '*CLS;' ...
                ':INSTrument \"SPA\";' ...
                ':FORMat:DATA REAL,32;' ...
                ':BANDwidth:VIDeo:TYPE LIN;' ...
                ':SWEep:MODE FAST;:GPS ON'])
            res = writeread(anl, "SYSTEM:ERROR?");
            if ~contains(res, "No error", "IgnoreCase", true)
                warning("ANRITSU: StartUp: " + res)
            else
                disp("ANRITSU: Start Ok.")
            end
        end

        function out = getParms(obj)
            keys = [
                "AVGType"...
                "AVGCount"...
                "Detection"...
                "UnitPower"...
                "FStart"...
                "FStop"...
                "ResAuto"...
                "Res"...
                "InputGain"...
                "AttAuto"...
                "Att"
                "SweepTime"
                "VBW"
                ];
            res = obj.getCMD("" + ...
                ":AVERage:TYPE?;" + ...
                ":AVERage:COUNt?;" + ...
                ":DETector:FUNCtion?;" + ...
                ":UNIT:POWer?;" + ...
                ":FREQuency:STARt?;" + ...
                ":FREQuency:STOP?;" + ...
                ":BANDwidth:RESolution:AUTO?;" + ...
                ":BANDwidth:RESolution?;" + ...
                ":POWer:RF:GAIN:STATe?;" + ...
                ":POWer:RF:ATTenuation:AUTO?;" + ...
                ":POWer:RF:ATTenuation?;" + ...
                ":SWEep:TIME:ACTual?;" + ...
                ":BANDwidth:VIDeo?"...
                );
            data = strsplit(res.', ';');
            out = dictionary(keys, data);
        end
        
        % TODO: Localizar controle do pre-amp.
        % function preAmp(obj, state)

        % TODO: A implementar:
        % function value = getMarker(obj, freq, trace)
        % function data = getTrace(obj, trace)
       
    end
end

