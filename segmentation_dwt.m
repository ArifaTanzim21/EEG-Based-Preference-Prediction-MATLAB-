clc;
clear all;
close all;

% Number of files 
num_files = 24;

% Initialize a cell array to store the imported data from each file
m_data = cell(1, num_files);

% Sampling frequency and epoch parameters
fs = 128; 
epoch_duration = 4;  % Duration of each epoch in seconds
samples_per_epoch = epoch_duration * fs;  % Number of samples per epoch

% Initialize a cell array to store epoch data
epoch_data_all = {};
epoch_labels = [];  % To store the label for each epoch

% Loop to load each CSV file and divide into epochs
k = 1;  % Initialize counter
for j = 1:1:12   % For the first part of the filename
    for i = 1:1:2   % For the second part of the filename
        % Create the filename dynamically based on j and i
        filename = sprintf('%d%d.csv', j, i);  % Generates filenames like '11.csv', '12.csv', ..., '122.csv'
        
        % Load the data from the CSV file
        eeg_data = readtable(filename);
        
        % Get the total number of rows (samples) in the file
        num_samples = height(eeg_data);
        
        % Calculate the number of epochs
        num_epochs = floor(num_samples / samples_per_epoch);
        
        % Determine label based on the second part of the filename (i=1 -> label 0, i=2 -> label 1)
        label = i - 1;  % i=1 becomes 0, i=2 becomes 1
        
        % Divide the data into 4-second epochs
        for epoch = 1:num_epochs
            start_idx = (epoch-1) * samples_per_epoch + 1;
            end_idx = epoch * samples_per_epoch;
             epoch_data = eeg_data(start_idx:end_idx, 2:17);  
            
            % Store each epoch's data in the cell array
            epoch_data_all{end+1} = epoch_data;  % Append epoch data to the cell array
            epoch_labels = [epoch_labels; label];  % Append label to the label array
        end
        
        % Display a message to confirm file loading and epoching
        disp(['Loaded and divided file: ', filename, ' into ', num2str(num_epochs), ' epochs.']);
        
        k = k + 1;  % Increment the counter to store the next file
        
        if k > num_files  % Stop loading after 24 files
            break;
        end
    end
end



% Initialize the final results matrix for all epochs
num_epochs_total = length(epoch_data_all);  % Total number of epochs across all files
final_results = zeros(num_epochs_total, 771);  % To store data for all epochs

% Process each epoch
for epoch_index = 1:num_epochs_total
    y = epoch_data_all{epoch_index}; % Data for the current epoch
    
    % Extract the numeric data from the table
    y_numeric = table2array(y);  % Convert the table to a numeric array
    
    % Apply the DWT for all channels
    for ch = 1:1:16
        % Pass the numeric data for the current channel to the dwt_sig function
        out(ch,:) = dwt_sig(y_numeric(:,ch), fs);  
    end
    
    % Initialize an array to store the results for this epoch
    results = zeros(1, 771);  % 16 channels x 48 features(12x4) + 2 for AW and Valence indices
    
    % Initialize variables for AW and Valence index calculation
    alpha_F3 = 0; beta_F3 = 0;
    alpha_F4 = 0; beta_F4 = 0;
    
    % Loop through each channel to compute statistics
    for ch = 1:1:16
        theta_ch = out(ch).theta;
        alpha_ch = out(ch).alpha;
        beta_ch = out(ch).beta;
        gamma_ch = out(ch).gamma;
        
        % Compute 12 metrics for each frequency band (theta, alpha, beta, gamma)
        theta_metrics = compute_metrics(theta_ch, fs);
        alpha_metrics = compute_metrics(alpha_ch, fs);
        beta_metrics = compute_metrics(beta_ch, fs);
        gamma_metrics = compute_metrics(gamma_ch, fs);
        
        % Store the results for each wave in the results array
        results(1, (ch-1)*48 + 1:(ch-1)*48 + 12) = theta_metrics;  % Store theta metrics
        results(1, (ch-1)*48 + 13:(ch-1)*48 + 24) = alpha_metrics;  % Store alpha metrics
        results(1, (ch-1)*48 + 25:(ch-1)*48 + 36) = beta_metrics;   % Store beta metrics
        results(1, (ch-1)*48 + 37:(ch-1)*48 + 48) = gamma_metrics;  % Store gamma metrics
        
        % Store alpha and beta power for F3 (ch 3) and F4 (ch 4)
        if ch == 3
            alpha_f3 = out(ch).alpha; 
            beta_f3 = out(ch).beta; 
            [pxx_alpha, f] = pwelch(alpha_f3, [], [], fs);
            alpha_F3 = bandpower(pxx_alpha, f, 'psd');
        
            [pxx_beta, f] = pwelch(beta_f3, [], [], fs);
            beta_F3 = bandpower(pxx_beta, f, 'psd');
        elseif ch == 4
            alpha_f4 = out(ch).alpha; 
            beta_f4 = out(ch).beta; 
            [pxx_alpha2, f] = pwelch(alpha_f4, [], [], fs);
            alpha_F4 = bandpower(pxx_alpha2, f, 'psd');
            
            [pxx_beta2, f] = pwelch(beta_f4, [], [], fs);
            beta_F4 = bandpower(pxx_beta2, f, 'psd');
        end
    end
    
    % Calculate AW and Valence indices
    AW_index = (alpha_F4 - alpha_F3) / (alpha_F4 + alpha_F3);  
    Valence_index = (beta_F3 / alpha_F3) - (beta_F4 / alpha_F4);  
    
    % Store the AW and Valence indices 
    results(1, 769) = AW_index;
    results(1, 770) = Valence_index;
    
    % Store the label (0 or 1) based on the file it came from in the 771th column
    results(1, 771) = epoch_labels(epoch_index);
    
    % Store the results for this epoch into the final results matrix
    final_results(epoch_index, :) = results;
end

% Display the resulting metrics matrix
disp('Computed metrics for each epoch :');
disp(final_results);

% Save the results to a CSV file
writematrix(final_results, 'metrics_values_dwt.csv');


%For xtest, xtrain, ytest, ytrain

data=importdata("metrics_values_dwt.csv");
x=data(:,1:(end-1));
y=data(:,end);
[row,col]=size(x);

for i=1:col
    x(:,i)=x(:,1)/max(x(:,i));
    
    x(:,i)=(x(:,1)-mean(x(:,i)))/std(x(:,i));
end


trainrat=0.8;

c=cvpartition(y,"HoldOut",1-trainrat);

trainidx=training(c);
testidx=test(c);

xtrain=x(trainidx,:);
ytrain=y(trainidx);
xtest=x(testidx,:);
ytest=y(testidx);

n=1;
ytrain=categorical(ytrain);
[xtrain,ytrain]=smote(xtrain,[0 n],25,"Class",ytrain);
ytrain=double(string(ytrain));

itotal=find(y==1);
itrain=find(ytrain==1);
itest=find(ytest==1);

