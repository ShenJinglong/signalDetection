clear;
close all;
clc;

data_board = DataBoard; % ���ݹ����������
sender = Sender(data_board); % �����
info_channel = InfoChannel(data_board); % �ŵ�
receiver = Receiver(data_board); % ���ջ�

for modulation_type = ["16QAM-cy", "16QAM"]
    data_board.reset(); % �������ݹ�����
    data_board.modulationType = modulation_type;
    while data_board.BER > 1e-5
        data_board.clear(); % ����ڲ�������
        data_board.SNR = data_board.SNR + 1; % ָ�������
        while data_board.bitError < 500
            signal_original = sender.sequenceGenerate(); % ������Դ����
            signal_modulated = sender.modulate(signal_original); % ����
            signal_received = info_channel.gaussian(signal_modulated); % ���ŵ�
            signal_recovered = receiver.detect(signal_received); % ���
        end
        data_board.organizeData(); % ��������
        disp(data_board.SNR);
    end
    plot(data_board); % ���ƽ��
end