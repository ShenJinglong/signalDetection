classdef Receiver
    properties (SetAccess = private)
        dataBoardHandle_
    end
    methods
        function obj = Receiver(dataBoardHandle)
            obj.dataBoardHandle_ = dataBoardHandle;
        end
        function out = detect(obj, in)
            if obj.dataBoardHandle_.modulationType == "BPSK"
                A = obj.dataBoardHandle_.A;
                star_points = [-A, A];
                [signal_detected, index] = obj.MLDetection(in, star_points);
                obj.dataBoardHandle_.signalDetected = signal_detected;
                out = index - 1;
                obj.dataBoardHandle_.signalRecovered = out;
            elseif obj.dataBoardHandle_.modulationType == "ASK"
                A = obj.dataBoardHandle_.A;
                star_points = [0, A];
                [signal_detected, index] = obj.MLDetection(in, star_points);
                obj.dataBoardHandle_.signalDetected = signal_detected;
                out = index - 1;
                obj.dataBoardHandle_.signalRecovered = out;
            elseif obj.dataBoardHandle_.modulationType == "16QAM"
                [signal_detected, index] = obj.MLDetection(in, obj.dataBoardHandle_.QAM16_Map);
                obj.dataBoardHandle_.signalDetected = signal_detected;
                out = reshape(de2bi(index - 1, 'left-msb').', [obj.dataBoardHandle_.sourceSequenceLength, 1]);
                obj.dataBoardHandle_.signalRecovered = out;
            elseif obj.dataBoardHandle_.modulationType == "16QAM-cy"
                out = reshape([imag(in) < 0, abs(imag(in)) < 2 * obj.dataBoardHandle_.A, ...
                        real(in) < 0, abs(real(in)) < 2 * obj.dataBoardHandle_.A].', [obj.dataBoardHandle_.sourceSequenceLength, 1]);
                obj.dataBoardHandle_.signalDetected = obj.MLDetection(in, obj.dataBoardHandle_.QAM16_Map);
                obj.dataBoardHandle_.signalRecovered = out;
            end
        end
    end
    methods (Access = private)
        function [out, index] = MLDetection(~, in, star_points)
            european_matrix = zeros(length(in), length(star_points));
            for ii = 1:length(star_points)
                european_matrix(:, ii) = abs(in - star_points(ii));
            end
            [~, index] = min(european_matrix, [], 2);
            out = star_points(index).';
        end
    end
end