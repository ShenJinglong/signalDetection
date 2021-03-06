classdef Sender
    properties (SetAccess = private)
        dataBoardHandle_
    end
    methods
        function obj = Sender(dataBoardHandle)
            obj.dataBoardHandle_ = dataBoardHandle;
        end
        function out = sequenceGenerate(obj)
            out = double(rand(obj.dataBoardHandle_.sourceSequenceLength, 1) > 0.5);
            obj.dataBoardHandle_.signalOriginal = out;
        end
        function out = modulate(obj, in)
            if obj.dataBoardHandle_.modulationType == "BPSK"
                out = (in .* 2 - 1) * obj.dataBoardHandle_.A;
                obj.dataBoardHandle_.signalModulated = out;
            elseif obj.dataBoardHandle_.modulationType == "ASK"
                out = in .* obj.dataBoardHandle_.A;
                obj.dataBoardHandle_.signalModulated = out;
%             elseif obj.dataBoardHandle_.modulationType == "16QAM"
%                 mid = reshape(in, [4, obj.dataBoardHandle_.sourceSequenceLength / 4]).';
%                 mid_de = bi2de(mid, 'left-msb') + 1;
%                 out = obj.dataBoardHandle_.QAM16_Map(mid_de).';
%                 obj.dataBoardHandle_.signalModulated = out;
            elseif obj.dataBoardHandle_.modulationType == "16QAM"
                mid = reshape(in, [4, obj.dataBoardHandle_.sourceSequenceLength / 4]);
                mid_de = mid(1, :) * 8 + mid(2, :) * 4 + mid(3, :) * 2 + mid(4, :) + 1;
                out = obj.dataBoardHandle_.QAM16_Map(mid_de).';
                obj.dataBoardHandle_.signalModulated = out;
            elseif obj.dataBoardHandle_.modulationType == "16QAM-cy"
                mid = reshape(in, [4, obj.dataBoardHandle_.sourceSequenceLength / 4]).';
                out = obj.dataBoardHandle_.A .* ((-2 .* mid(:,3) + 1) .* (-2 .* mid(:, 4) + 3) ...
                        + 1j .* (-2 * mid(:, 1) + 1) .* (-2 * mid(:, 2) + 3));
                obj.dataBoardHandle_.signalModulated = out;
            end
        end
    end
end