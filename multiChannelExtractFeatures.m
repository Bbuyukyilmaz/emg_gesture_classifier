function features = multiChannelExtractFeatures(emgSignal)
    % emgSignal is a matrix of size [num_samples_per_gesture x num_channels]

    % Pre-allocate features matrix
    num_features_per_channel = 5; % Number of features per channel
    num_channels = size(emgSignal, 2);
    features = zeros(1, num_features_per_channel * num_channels);
    
    % Calculate features for each channel
    % Mean Absolute Value (MAV)
    mav = mean(abs(emgSignal), 1);
    
    % Zero Crossings (ZC)
    zc = sum(diff(emgSignal > 0, 1, 1), 1);
    
    % Slope Sign Changes (SSC)
    ssc = zeros(1, num_channels);
    for ch = 1:num_channels
        for i = 2:size(emgSignal, 1) - 1
            if (emgSignal(i-1, ch) - emgSignal(i, ch)) * (emgSignal(i, ch) - emgSignal(i+1, ch)) > 0
                ssc(ch) = ssc(ch) + 1;
            end
        end
    end
    
    % Waveform Length (WL)
    wl = sum(abs(diff(emgSignal, 1, 1)), 1);
    
    % Root Mean Square (RMS)
    rms = sqrt(mean(emgSignal.^2, 1));
    
    % Combine features for all channels 
    features = [mav, zc, ssc, wl, rms];
end

