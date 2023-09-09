classdef EB500 < R_S
    methods
        function obj = EB500(~, args)
            obj@R_S('EB500', args)
        end

        function startUp(obj)
            anl = tcpclient( obj.prop('ip'), double(obj.prop('port')) );
            writeline(anl, ['' ...
                '*CLS;' ...
                ':SYST:COMM:LAN:PING 0;' ...
                ':TRAC:UDP:DELete ALL;' ...
                ':ROUTe:AUTO 0;' ...
                ':OUTPut:AUXMode AUTO;' ...
                ':MEASure:APPL RX;' ...
                ':FREQ:MODE PSCAN;' ...
                ':FUNCtion:CONCurrent OFF;' ...
                ':MEAS:MODE PER;' ...
                ':SYSTem:GPS:DATA:AUTO 1;' ...
                ':INITiate:IMMediate'])
            res = writeread(anl, "SYSTEM:ERROR?");
            if ~contains(res, "No error", "IgnoreCase", true)
                warning("EB500: StartUp: " + res)
            else
                disp("EB500: Start Ok.")
            end
            clear anl;
        end
    end

    methods (Access = private)
        function udp = setStreamUDP(obj, port)
            udp = obj.udpport(port); % streaming PSCAN, GPS (drive-test)
        end
    end
end