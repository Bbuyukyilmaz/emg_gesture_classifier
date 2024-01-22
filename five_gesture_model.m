%%
% Number of gestures
num_gestures = 6;  % Assuming you have 10 different gestures
num_samples_per_gesture = 12000; % Number of samples per gesture iteration
num_channels = 4; % Number of channels in the new data
num_samples = size(gui_data, 3);

% Number of versions for each gesture
num_versions = num_samples / num_gestures; % Assuming 1000 total versions

% Create the label vector
gui_labels = repmat(1:num_gestures, 1, num_versions)';

% For a 4-channel signal with 5 features per channel
num_features_per_channel = 5;
total_num_features = num_features_per_channel * num_channels; % 20 in this case

% Pre-allocate matrix for feature vectors
feature_vectors = zeros(num_samples, total_num_features);

% Extract features from each signal iteration
for i = 1:num_samples
    % Reshape the i-th sample to be a 2D matrix of size [num_samples_per_gesture, num_channels]
    current_sample = reshape(gui_data(:,:,i), num_samples_per_gesture, num_channels);
    feature_vectors(i, :) = multiChannelExtractFeatures(current_sample);
end

% Normalize the features
global gui_normalized_features;
gui_normalized_features = zscore(feature_vectors);



%%
% Number of gestures
num_gestures = 6;  % Assuming you have 10 different gestures
num_samples_per_gesture = 12000; % Number of samples per gesture iteration
num_channels = 4; % Number of channels in the new data
num_samples = size(five_gesture_multi_channel_gesture_data, 3);

% Number of versions for each gesture
num_versions = num_samples / num_gestures; % Assuming 1000 total versions

% Create the label vector
train_labels = repmat(1:num_gestures, 1, num_versions)';
%%
% For a 4-channel signal with 5 features per channel
num_features_per_channel = 5;
total_num_features = num_features_per_channel * num_channels; % 20 in this case

% Pre-allocate matrix for feature vectors
feature_vectors = zeros(num_samples, total_num_features);

%%
% Extract features from each signal iteration
for i = 1:num_samples
    % Reshape the i-th sample to be a 2D matrix of size [num_samples_per_gesture, num_channels]
    current_sample = reshape(five_gesture_multi_channel_gesture_data(:,:,i), num_samples_per_gesture, num_channels);
    feature_vectors(i, :) = multiChannelExtractFeatures(current_sample);
end

% Normalize the features
normalized_features = zscore(feature_vectors);

%%
test_num_samples = size(five_gesture_multi_channel_test_data, 3);

% Number of versions for each gesture
test_num_versions = test_num_samples / num_gestures; % Assuming 1000 total versions

% Create the label vector
test_labels = repmat(1:num_gestures, 1, test_num_versions)';
total_num_features = num_features_per_channel * num_channels; % 20 in this case


% Pre-allocate matrix for feature vectors
test_feature_vectors = zeros(test_num_samples, total_num_features);

%%
% Extract features from each signal iteration
for i = 1:test_num_samples
    % Reshape the i-th sample to be a 2D matrix of size [num_samples_per_gesture, num_channels]
    current_sample = reshape(five_gesture_multi_channel_test_data(:,:,i), num_samples_per_gesture, num_channels);
    test_feature_vectors(i, :) = multiChannelExtractFeatures(current_sample);
end

% Normalize the features
global normalized_test_features;
normalized_test_features = zscore(test_feature_vectors);


%%
% Create a random permutation of indices
shuffle_indices = randperm(num_samples);

% Shuffle the features and labels using the same permutation
shuffled_features = normalized_features(shuffle_indices, :);
shuffled_labels = train_labels(shuffle_indices);

% Shuffle test set
test_shuffle_indices = randperm(test_num_samples);
shuffled_test_features = normalized_test_features(test_shuffle_indices, :);
shuffled_test_labels = test_labels(test_shuffle_indices);


%%
% Define the SVM template with the RBF kernel
template = templateSVM('KernelFunction', 'rbf', 'BoxConstraint', 10, 'KernelScale', 10, 'Standardize', true);

% Train the multi-class model using the One-vs-One approach
global SVMModel;
SVMModel = fitcecoc(shuffled_features, shuffled_labels, 'Learners', template, 'Coding', 'onevsone');

% Predict the labels of the test data using the trained model
predicted_labels = predict(SVMModel, shuffled_test_features);

% Calculate and display the overall accuracy
accuracy = mean(predicted_labels == shuffled_test_labels);
disp(['Test Accuracy with One-vs-One SVM: ', num2str(accuracy * 100), '%']);

% Create and visualize a confusion matrix
C = confusionmat(shuffled_test_labels, predicted_labels);
figure;
confusionchart(C);
title('One-vs-One SVM Confusion Matrix');

%%

% Define the range of parameters for the grid search
C_values = [0.1, 1, 10, 100];
gamma_values = [0.01, 0.1, 1, 10];

% Initialize variables to store the best parameters and highest accuracy
bestC = 0;
bestGamma = 0;
highestAccuracy = 0;

% Loop over all possible combinations of C and gamma for the RBF kernel
for C = C_values
    for gamma = gamma_values
        % Debug print: current parameters being trained
        fprintf('Training with C = %f, gamma = %f\n', C, gamma);
        
        % Create a template for SVM with RBF kernel and current set of parameters
        template = templateSVM('KernelFunction', 'rbf', 'BoxConstraint', C, 'KernelScale', gamma, 'Standardize', true);
        
        % Train the model using the template
        SVMModel = fitcecoc(shuffled_features, shuffled_labels, 'Learners', template, 'Coding', 'onevsall');
        
        % Predict the labels of the test data using the trained model
        predicted_labels = predict(SVMModel, shuffled_test_features);

        % Calculate and display the overall accuracy
        accuracy = mean(predicted_labels == shuffled_test_labels);

        % Update the best parameters if the current model is better
        if accuracy > highestAccuracy
            highestAccuracy = accuracy;
            bestC = C;
            bestGamma = gamma;
        end
    end
end

% Output the best parameters and the corresponding accuracy
fprintf('Best parameters found:\n');
fprintf('C = %f, gamma = %f\n', bestC, bestGamma);
fprintf('Highest accuracy: %.2f%%\n', highestAccuracy * 100);

% Optionally: retrain the model with the best parameters on the full training set
bestTemplate = templateSVM(...
    'KernelFunction', 'rbf', ...
    'BoxConstraint', bestC, ...
    'KernelScale', bestGamma, ...
    'Standardize', true);

bestSVMModel = fitcecoc(shuffled_features, shuffled_labels, ...
    'Learners', bestTemplate, ...
    'Coding', 'onevsall');

% Predict the labels of the test data using the best trained model
predicted_labels = predict(bestSVMModel, shuffled_test_features);

% Calculate and display the overall accuracy with the best model
finalAccuracy = mean(predicted_labels == shuffled_test_labels);
disp(['Test Accuracy with Best Parameters: ', num2str(finalAccuracy * 100), '%']);

% Create and visualize a confusion matrix with the best model
finalC = confusionmat(shuffled_test_labels, predicted_labels);
figure;
confusionchart(finalC);
title('SVM Confusion Matrix with Best Parameters');








