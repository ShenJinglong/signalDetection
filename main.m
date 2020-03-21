clear;
close all;
clc;

data_board = DataBoard; % 数据管理器，句柄
sender = Sender(data_board); % 发射机
info_channel = InfoChannel(data_board); % 信道
receiver = Receiver(data_board); % 接收机

for modulation_type = ["16QAM-cy", "16QAM"]
    data_board.reset(); % 重置数据管理器
    data_board.modulationType = modulation_type;
    while data_board.BER > 1e-5
        data_board.clear(); % 清除内部计数器
        data_board.SNR = data_board.SNR + 1; % 指定信噪比
        while data_board.bitError < 500
            signal_original = sender.sequenceGenerate(); % 生成信源序列
            signal_modulated = sender.modulate(signal_original); % 调制
            signal_received = info_channel.gaussian(signal_modulated); % 过信道
            signal_recovered = receiver.detect(signal_received); % 检测
        end
        data_board.organizeData(); % 整理数据
        disp(data_board.SNR);
    end
    plot(data_board); % 绘制结果
end