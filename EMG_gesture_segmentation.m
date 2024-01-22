%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% This code is used for the segmentation of the sEMG signals in the dataset titled                %%%
%%% "Dataset for multi-channel surface electromyography (sEMG) signals of hand gestures"            %%%                                                            
%%% Mendeley Repository: http://dx.doi.org/10.17632/ckwc76xr2z.2                                    %%%
%%%                                                                                                 %%%
%%% Written by Mehmet Akif Ozdemir.                                                                 %%%
%%% Izmir Katip Celebi University                                                                   %%%
%%% Department of Biomedical Engineering                                                            %%%
%%% makif.ozdemir@ikcu.edu.tr                                                                       %%%
%%% 21/12/2021                                                                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
close all
clc
test_index = 1;
index = 1;
multi_channel_test_index = 1;
multi_channel_index = 1;
five_gesture_multi_channel_test_index = 1;
five_gesture_multi_channel_index = 1;
gui_data_index = 1;
% Dimensions
num_data_points = 12000; % Number of data points per signal
num_rep = 5;        % Number of channels
num_gestures = 10;       % Number of gestures
num_train_participants = 32;   % Number of participants for train
num_test_participants = 8;   % Number of participants for test
num_gui_participants = 1;

% Initialize the all_gesture_data variable
gesture_data = zeros(num_data_points, num_rep*num_gestures*num_train_participants);
test_data = zeros(num_data_points, num_rep*num_gestures*num_test_participants);


multi_channel_gesture_data = zeros(num_data_points,4 , num_rep*num_gestures*num_train_participants);
multi_channel_test_data = zeros(num_data_points,4 ,num_rep*num_gestures*num_test_participants);

num_gestures = 6;
five_gesture_multi_channel_gesture_data = zeros(num_data_points,4 , num_rep*num_gestures*num_train_participants);
global five_gesture_multi_channel_test_data;
five_gesture_multi_channel_test_data = zeros(num_data_points,4 ,num_rep*num_gestures*num_test_participants);
num_rep = 1;
gui_data = zeros(num_data_points,4 ,num_rep*num_gestures*num_gui_participants);

num_signals = 5;       % Total number of signals
signal_length = 12000; % Length of each signal

% Pre-allocate a matrix to store all signals
combined_signals = zeros(signal_length, num_signals);

fs = 2000; % sampling rate "Hz"

%% DESIRED sEMG SEGMENTS LENGTH as second
signal_segment_starting=0; % indicate the desired beginning of segment as sec (usually 0 or 1)
signal_segment_ending=6; %indicate the desired ending of segment as sec (usually 5 or 6)
%ATTENTION: signal_segment_long=signal_segment_ending-signal_segment_starting; % max segment long is 6
%if you want to use sEMG segments which gestures are not beginning you can change the signal_segment_starting like -1

%% Get sEMG Records directory:
current_folder= '..\ckwc76xr2z-2'; %  !!!change with current folder!!!
addpath(genpath(current_folder))
Base  = strcat(current_folder,'\sEMG-dataset\filtered\mat'); % filtered recommended, change with raw or filtered
List  = dir(fullfile(Base, '**', '*.mat'));
Files = fullfile({List.folder}, {List.name});
matches = regexp(Files, '\d+', 'match');
Nd = zeros(size(matches));
for i = 1:length(matches)
    % Assuming the first number in each filename is the sorting criterion
    Nd(i) = str2double(matches{i}{1});
end

[~,I] = sort(Nd);
Files = Files(I);

%%Using for automated segmentation of all participant sEMG data to sEMG gesture segment.
for iFile = 1:numel(Files) %40 participants, each sEMG data channel consist 1280000=640 sec* 2000 fs data point

    load(Files{iFile}) % load .. sEMG data of participants
    % Each File consists of : "data"        : discrete 4 ch sEMG signals
    %                         "fs"          : sampling rate as "2000"
    %                         "iD"          : participant iD as " 1 to 40"
    %                         "isi"         : sampling interval as "0.5"
    %                         "isi_units"   : sampling interval unit as "ms"
    %                         "labels"      : current channels' labels
    %                         "start_sample": start time of the signal recording as "0"
    %                         "units"       : sEMG data units as "mV"


    for rep=0:4 % 5 repetition, one cycle took 104 sec + 30 sec resting time, total 134 second fifth cycye only took 104 sec

        if rep==0
            rep_coeff=4; % first cycle: first REST start at fourth second and this cycle took 134 sec
        elseif rep==1
            rep_coeff=138; % second cycle: REST start at 138 sec= 104 sec (first cycle) + 30 sec (long rest) + 4 sec (begening rest)
        elseif rep==2
            rep_coeff=272; % third cycle: REST start at 272 sec= 268 sec (first two cycles) + 4 sec (begening rest)
        elseif rep==3
            rep_coeff=406; % fourth cycle: REST start at 406 sec= 402 sec (first three cycles) + 4 sec (begening rest)
        elseif rep==4
            rep_coeff=540; % fifth cycle: REST start at 540 sec= 536 sec (first four cycles) + 4 sec (begening rest)
        end % end is 640 sec


        for gesture =0:9 % a total of 10 hand gesture
            %0: X = REST
            %1: E = EXTENSION
            %2: F = FLEXION
            %3: U = ULNAR DEVIATION
            %4: R = RADIAL DEVIATION
            %5: G = GRIP
            %6: B = ABDUCTION
            %7: D = ADDUCTION
            %8: S = SUPINATION
            %9: P = PRONATION

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%USE THE CODE BELOW FOR YOUR MULTI-CHANNEL ANALYSIS%%%
            multi_channel_sEMG_data=data((signal_segment_starting+rep_coeff+(gesture*10))*fs+1:...
                ((rep_coeff+(gesture*10))+signal_segment_ending)*fs,:);
            % It provides 6 seconds sEMG data of a single gesture belonging to 4-channel sEMG data.
        

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%                 USE HERE "multi_channel_sEMG_data" TO ANALYZE               %%%                                                                      %%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if(iFile < 33)
                    multi_channel_gesture_data(:,:,multi_channel_index) = multi_channel_sEMG_data;

                    % figure;
                    % % Initialize an array to store axis handles
                    % ax = zeros(4, 1);
                    % 
                    % % Plot data from channel 1
                    % ax(1) = subplot(4,1,1); % Creates a 2x2 grid, and places the following plot in the 1st position
                    % plot(multi_channel_gesture_data(:,1,multi_channel_index));
                    % title('Channel 1');
                    % 
                    % % Plot data from channel 2
                    % ax(2) = subplot(4,1,2); % Places the following plot in the 2nd position
                    % plot(multi_channel_gesture_data(:,2,multi_channel_index));
                    % title('Channel 2');
                    % 
                    % % Plot data from channel 3
                    % ax(3) = subplot(4,1,3); % Places the following plot in the 3rd position
                    % plot(multi_channel_gesture_data(:,3,multi_channel_index));
                    % title('Channel 3');
                    % 
                    % % Plot data from channel 4
                    % ax(4) = subplot(4,1,4); % Places the following plot in the 4th position
                    % plot(multi_channel_gesture_data(:,4,multi_channel_index));
                    % title('Channel 4');
                    % 
                    % % Link all axes to have the same scale
                    % linkaxes(ax, 'xy');
                    % 
                    % % Add global title
                    % sgtitle('4 Channel Data');
                    % 
                    multi_channel_index = multi_channel_index + 1;

                end
                if(iFile >= 33)
                    multi_channel_test_data(:, :,multi_channel_test_index) = multi_channel_sEMG_data;
                    multi_channel_test_index = multi_channel_test_index + 1;
                end

                if(iFile < 33 && (gesture == 0 || gesture == 1 || gesture == 2 || gesture == 3 || gesture == 4 || gesture == 5))
                    five_gesture_multi_channel_gesture_data(:,:,five_gesture_multi_channel_index) = multi_channel_sEMG_data;
                    five_gesture_multi_channel_index = five_gesture_multi_channel_index + 1;

                end
                if(iFile >= 33 && (gesture == 0 || gesture == 1 || gesture == 2 || gesture == 3 || gesture == 4 || gesture == 5))
                    five_gesture_multi_channel_test_data(:, :,five_gesture_multi_channel_test_index) = multi_channel_sEMG_data;
                    five_gesture_multi_channel_test_index = five_gesture_multi_channel_test_index + 1;
                end
                if(iFile == 35 && (gesture == 0 || gesture == 1 || gesture == 2 || gesture == 3 || gesture == 4 || gesture == 5) && rep == 0)
                    gui_data(:,:,gui_data_index) = multi_channel_sEMG_data;
                    gui_data_index = gui_data_index + 1;
                end
                


            switch gesture
                case 0%0: X = REST
                    %% Do something in here for REST segment i.e. save the multi-channel signal segment or
                    % make the multivariate anaylsis of the multi-channel segment, etc.
                    % Rest_signal_multiCH=multi_channel_sEMG_data;
                    % Example= plot(Rest_signal_multiCH);
                case 1%1: E = EXTENSION

                case 2%2: F = FLEXION

                case 3%3: U = ULNAR DEVIATION

                case 4%4: R = RADIAL DEVIATION

                case 5%5: G = GRIP

                case 6%6: B = ABDUCTION

                case 7%7: D = ADDUCTION

                case 8%8: S = SUPINATION

                case 9%9: P = PRONATION

            end %gesture swtich

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            %%%USE THE CODE BELOW FOR YOUR CHANNEL BASED ANALYSIS%%%
            for channel=1:4 % 4 ch sEMG data
                single_channel_sEMG_data=data((signal_segment_starting+rep_coeff+(gesture*10))*fs+1:...
                    ((rep_coeff+(gesture*10))+signal_segment_ending)*fs,channel);
                % The above code lines loops through all the repetitions, all the channels,
                % and all the gestures of all the participants, respectively, with the for loops.
                % It provides 6 seconds sEMG data of a single gesture belonging to a single channel.


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                %%%                 USE HERE "single_channel_sEMG_data" TO ANALYZE              %%%                                                                      %%
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                if(iFile < 31 && channel == 1)
                    gesture_data(:, index) = single_channel_sEMG_data;
                    index = index + 1;
                end
                if(iFile >= 31 && channel == 1)
                    test_data(:, test_index) = single_channel_sEMG_data;
                    test_index = test_index + 1;
                end
                
                
                switch gesture
                    case 0%0: X = REST
                        %% Do something in here for REST segment i.e. save the single-channel signal segment or
                        % take the STFT of the single-channel segment, etc.
                        % Rest_signal_singleCH=single_channel_sEMG_data;
                        % Example= plot(Rest_signal_singleCH);
                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_0 = single_channel_sEMG_data;
                        end
                    case 1%1: E = EXTENSION
                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_1 = single_channel_sEMG_data;
                        end

                        
                    case 2%2: F = FLEXION
                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_2 = single_channel_sEMG_data;
                        end
        

                    case 3%3: U = ULNAR DEVIATION
                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_3 = single_channel_sEMG_data;
                        end


                    case 4%4: R = RADIAL DEVIATION
                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_4 = single_channel_sEMG_data;
                        end


                    case 5%5: G = GRIP
                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_5 = single_channel_sEMG_data;
                        end

                    case 6%6: B = ABDUCTION

                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_6 = single_channel_sEMG_data;
                        end

                    case 7%7: D = ADDUCTION

                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_7 = single_channel_sEMG_data;
                        end

                    case 8%8: S = SUPINATION

                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_8 = single_channel_sEMG_data;
                        end

                    case 9%9: P = PRONATION

                        if(iFile == 21 && rep == 1 && channel == 1)
                            p2_gesture_data_9 = single_channel_sEMG_data;
                        end

                end %gesture swtich
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end%channel for

        end%gesture for

    end%repetition for

end%participants for