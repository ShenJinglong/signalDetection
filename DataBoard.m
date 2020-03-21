classdef DataBoard < handle
    properties (Constant)
        sourceSequenceLength = 100000; % ��Դ���г���
        sourcePower = 1; % ��Դ�źŹ��� W
    end
    properties
        modulationType = ""; % ���Ʒ�ʽ
        A = 0; % �źŷ���
        R = 0; % ����
        QAM16_Map = [-3 + 3i, -1 + 3i, 1 + 3i, 3 + 3i, ...
                     -3 + 1i, -1 + 1i, 1 + 1i, 3 + 1i, ...
                     -3 - 1i, -1 - 1i, 1 - 1i, 3 - 1i, ...
                     -3 - 3i, -1 - 3i, 1 - 3i, 3 - 3i]; % QAM16ӳ���
        SNR_Rec = []; % ����ȼ�¼��
        BER_Rec = []; % �����ʼ�¼��
        SER_Rec = []; % ������ʼ�¼��
        BER_Theo_Rec = []; % ����������ֵ��¼��
        SER_Upper_Rec = []; % ����������޼�¼��
        noisePower = inf; % �������� W
        SNR = 0; % ����� dB
        BER = inf; % ������
        SER = inf; % �������
    end
    properties
        bitTransfered = 0; % �ѷ��͵ı�����
        bitError = 0; % ����ı�����
        symbolTransfered = 0; % �ѷ��͵ķ�����
        symbolError = 0; % ����ķ�����
    end
    properties
        signalOriginal = []; % ԭʼ��Դ����
        signalModulated = []; % ���ƺ��ź�����
        signalDetected = []; % ������ź�
        signalRecovered = []; % �ָ����ź�
    end
    methods
        function plot(obj)
            if obj.modulationType == "BPSK"
                figure(1);
                semilogy(obj.SNR_Rec, obj.BER_Rec, obj.SNR_Rec, obj.BER_Theo_Rec);
                grid on;
            elseif obj.modulationType == "ASK"
                figure(1);
                hold on;
                semilogy(obj.SNR_Rec, obj.BER_Rec, obj.SNR_Rec, obj.BER_Theo_Rec);
                legend("BPSK BER", "BPSK BER Theo", "ASK BER", "ASK BER Theo");
                hold off;
            elseif obj.modulationType == "16QAM"
                figure(2);
                semilogy(obj.SNR_Rec, obj.BER_Rec);
                hold on;
                semilogy(obj.SNR_Rec, obj.SER_Rec);
                semilogy(obj.SNR_Rec, obj.SER_Upper_Rec);
                grid on;
                legend(obj.modulationType + " BER", obj.modulationType + " SER", obj.modulationType + " SER Upper");
                hold off;
                scatterplot(obj.QAM16_Map);
                map_str = [" 0000", " 0001", " 0010", " 0011", ...
                           " 0100", " 0101", " 0110", " 0111", ...
                           " 1000", " 1001", " 1010", " 1011", ...
                           " 1100", " 1101", " 1110", " 1111",];
                for jj = 1:length(obj.QAM16_Map)
                    text(real(obj.QAM16_Map(jj)), imag(obj.QAM16_Map(jj)), map_str(jj));
                end
            end
        end
        function organizeData(obj)
            obj.SNR_Rec = [obj.SNR_Rec, obj.SNR];
            obj.BER_Rec = [obj.BER_Rec, obj.BER];
            obj.SER_Rec = [obj.SER_Rec, obj.SER];
            if obj.modulationType == "BPSK"
                d = sqrt((-obj.A - obj.A)^2 / (obj.noisePower / 2));
                obj.BER_Theo_Rec = [obj.BER_Theo_Rec, 1 - normcdf(d / 2)];
            elseif obj.modulationType == "ASK"
                d = sqrt((0 - obj.A)^2 / (obj.noisePower / 2));
                obj.BER_Theo_Rec = [obj.BER_Theo_Rec, 1 - normcdf(d / 2)];
            elseif obj.modulationType == "16QAM"
                upper = 4 * (1 - normcdf(sqrt(3 * obj.sourcePower / (15 * obj.noisePower))));
                obj.SER_Upper_Rec = [obj.SER_Upper_Rec, upper];
            end
        end
        function clear(obj)
            obj.bitTransfered = 0;
            obj.bitError = 0;
            obj.symbolTransfered = 0;
            obj.symbolError = 0;
        end
        function reset(obj)
            obj.SNR_Rec = [];
            obj.BER_Rec = [];
            obj.SER_Rec = [];
            obj.SER_Upper_Rec = [];
            obj.BER_Theo_Rec = [];
            obj.noisePower = inf;
            obj.SNR = 0;
            obj.BER = inf;
        end
        function set.SNR(obj, val)
            obj.SNR = val;
            obj.noisePower = obj.sourcePower / (10^(0.1 * obj.SNR));
        end
        function set.signalRecovered(obj, val)
            obj.signalRecovered = val;
            obj.bitError = obj.bitError + sum(obj.signalRecovered ~= obj.signalOriginal);
            obj.bitTransfered = obj.bitTransfered + obj.sourceSequenceLength;
            obj.BER = obj.bitError / obj.bitTransfered;
            obj.symbolError = obj.symbolError + sum(obj.signalDetected ~= obj.signalModulated);
            obj.symbolTransfered = obj.symbolTransfered + (obj.sourceSequenceLength / obj.R);
            obj.SER = obj.symbolError / obj.symbolTransfered;
        end
        function set.modulationType(obj, val)
            obj.modulationType = val;
            if obj.modulationType == "BPSK"
                obj.A = sqrt(obj.sourcePower);
                obj.R = 1;
            elseif obj.modulationType == "ASK"
                obj.A = sqrt(2 * obj.sourcePower);
                obj.R = 1;
            elseif obj.modulationType == "16QAM"
                obj.A = sqrt(obj.sourcePower / 10);
                obj.R = 4;
                obj.QAM16_Map = obj.QAM16_Map .* obj.A;
            end
        end
    end
end