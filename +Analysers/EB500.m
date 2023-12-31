classdef EB500 < Analysers.Rohde_Schwarz
    methods
        function obj = EB500(~, args)
            obj@Analysers.Rohde_Schwarz('EB500', args)
        end

        function startUp(obj)
            anl = tcpclient( obj.prop('ip'), double(obj.prop('port')) );
            writeline(anl, "" + ...
                "*CLS;" + ...
                ":SYST:COMM:LAN:PING 0;" + ...
                ":TRAC:UDP:DELete ALL;" + ...
                ":ROUTe:AUTO 0;" + ...
                ":OUTPut:AUXMode AUTO;" + ...
                ":MEASure:APPL RX;" + ...
                ":FREQ:MODE PSCAN;" + ...
                ":FUNCtion:CONCurrent OFF;" + ...
                ":MEAS:MODE PER;" + ...
                ":SYSTem:GPS:DATA:AUTO 1;" + ...
                ":INITiate:IMMediate")
            res = writeread(anl, "SYSTEM:ERROR?");
            if ~contains(res, "No error", "IgnoreCase", true)
                warning("EB500: StartUp: " + res)
            else
                disp("EB500: Start Ok.")
            end
            clear anl;
        end

        function out = getParms(obj)
            keys = [
                "IFPanAVGType"...
                "FStart"...
                "FStop"...
                "PScanSTEP"...
                "IFPANBandwidth"...
                "IFPanSelectivity"...
                "AttMode"...
                "AttAuto"...
                "Att"...
                "FStartMin"...
                "FStopMax" ];
            res = obj.getCMD("" + ...
                ":CALCulate:IFPan:AVERage:TYPE?;" + ...
                ":FREQuency:PSCan:START?;" + ...
                ":FREQuency:PSCan:STOP?;" + ...
                ":PSCan:STEP?;" + ...
                ":CALCulate:IFPan:BANDwidth?;" + ...
                ":CALCulate:IFPan:SELectivity?;" + ...
                ":INPut:ATTenuation:MODE?;" + ...
                ":INPut:ATTenuation:AUTO?;" + ...
                ":INPut:ATTenuation?;" + ...
                ":FREQuency:STARt? MIN;" + ...
                ":FREQuency:STOP? MAX");
            data = strsplit(res, ';');
            out = dictionary(keys, data);
        end
    end

    methods (Access = private)
        function udp = setStreamUDP(obj, port)
            udp = obj.udpport(port); % streaming PSCAN, GPS (drive-test)
        end
    end
end