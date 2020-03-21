classdef InfoChannel
    properties (SetAccess = private)
        dataBoardHandle_
    end
    methods
        function obj = InfoChannel(dataBoardHandle)
            obj.dataBoardHandle_ = dataBoardHandle;
        end
        function out = gaussian(obj, in)
            if obj.dataBoardHandle_.modulationType ~= "16QAM"
                out = in + normrnd(0, sqrt(obj.dataBoardHandle_.noisePower / 2), length(in), 1);
            else
                out = in + normrnd(0, sqrt(obj.dataBoardHandle_.noisePower / 2), length(in), 1) + ...
                    normrnd(0, sqrt(obj.dataBoardHandle_.noisePower / 2), length(in), 1) * 1j;
            end
        end
    end
end