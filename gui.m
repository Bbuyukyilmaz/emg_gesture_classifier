function my_custom_gui
close all
global resized_img_p;
global resized_img_f;
global resized_img_ok;
global resized_img_cl;
global resized_img_op;
global resized_img_ro;
img_p = imread('hand_pointing.jpeg');
img_f = imread('hand_f.jpeg');
img_ok = imread('hand_ok.jpeg');
img_op = imread('hand_open.jpeg');
img_cl = imread('hand_closed.jpeg');
img_ro = imread('hand_rock.jpeg');
resized_img_p  = imresize(img_p , [300, 400]);
resized_img_f  = imresize(img_f , [300, 400]);
resized_img_ok = imresize(img_ok, [300, 400]);
resized_img_op = imresize(img_op, [300, 400]);
resized_img_cl = imresize(img_cl, [300, 400]);
resized_img_ro = imresize(img_ro, [300, 400]);

global f_plot_opened;
global f_plot;
f_plot_opened = 0;
% Create the serial port object here
    device = serialport("COM3", 115200);

 % Create the main GUI figure
    fig = figure('Name', 'Custom Function Executor', 'NumberTitle', 'off', ...
                 'Position', [500, 500, 400, 300]);

    % Define button positions
    buttonPositions = [50, 220, 100, 40;   % Button 1
                       50, 170, 100, 40;   % Button 2
                       50, 120, 100, 40;   % Button 3
                       250, 220, 100, 40;  % Button 4
                       250, 170, 100, 40;  % Button 5
                       250, 120, 100, 40]; % Button 6
    
    % Create six buttons
    for i = 1:6
        uicontrol('Style', 'pushbutton', 'String', ['Gesture ' num2str(i)], ...
                  'Position', buttonPositions(i, :), ...
                  'Callback', @(src,evnt)buttonCallback(i));
    end
    % Callback function for the Execute Function button
    function buttonCallback(buttonNumber)
        % Call your custom function here and pass the device
        myCustomFunction(device, buttonNumber);
    end

    % Function to close the serial port and figure
    function closeGUI(src, callbackdata)
        % Close and delete the serial port
        if isvalid(device)
            delete(device);
        end

        % Delete the figure
        delete(fig);
    end
end

function myCustomFunction(device, buttonNumber)
global f_plot_opened;
global f_plot;
if( f_plot_opened == 1)
    close(f_plot);
    f_plot_opened = 0;
end 
    % Your custom function with the device as an argument
    global SVMModel;
    global normalized_test_features;
    global five_gesture_multi_channel_test_data
    randomNumber = (randi([1, 40]) - 1) * 6 + buttonNumber;
f_plot = figure;
tiledlayout(3,2)
for i = 1:4
    nexttile
    % subplot(2, , i); % Create a 2x2 grid of subplots, and plot in the i-th subplot
    plot(five_gesture_multi_channel_test_data(:,i,randomNumber));
    title(['Channel ' num2str(i)]); % Optional: Add title to each subplot
    f_plot_opened = 1;
end

    
    %%
    gui_predicted_label = predict(SVMModel, normalized_test_features(randomNumber,:));
    gui_u8_predicted_label = uint8(gui_predicted_label) + 15;
    global resized_img_p;
    global resized_img_f;
    global resized_img_ok;
    global resized_img_cl;
    global resized_img_op;
    global resized_img_ro;
    nexttile([1 2])
    switch buttonNumber
        case 1
           imshow(resized_img_p); 
        case 2
           imshow(resized_img_cl); 
        case 3
           imshow(resized_img_ro); 
        case 4
           imshow(resized_img_f); 
        case 5
           imshow(resized_img_ok); 
        case 6
           imshow(resized_img_op); 
    end
    


   %%
   send_buf = [0xA5 gui_u8_predicted_label 0 0 0 0xAB 0xCD];
   write(device, send_buf, "uint8");
end
