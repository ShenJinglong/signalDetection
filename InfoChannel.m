classdef InfoChannel
    properties (SetAccess = private)
        dataBoardHandle_
    end
    methods
        function obj = InfoChannel(dataBoardHandle)
            obj.dataBoardHandle_ = dataBoardHandle;
        end
        function out = gaussian(obj, in)
            if isreal(in)
                out = in + normrnd(0, sqrt(obj.dataBoardHandle_.noisePower / 2), length(in), 1);
            else
                out = in + normrnd(0, sqrt(obj.dataBoardHandle_.noisePower / 2), length(in), 1) + ...
                    normrnd(0, sqrt(obj.dataBoardHandle_.noisePower / 2), length(in), 1) * 1j;
            end
        end
    end
end