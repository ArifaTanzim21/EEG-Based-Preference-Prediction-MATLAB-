function metrics = compute_metrics(signal, fs)
    % Compute the PSD using pwelch
    [Pxx, f] = pwelch(signal, [], [], fs);
     % Extract the PSD in the range of 0.5 to 45 Hz
    idx = f >= 0.5 & f <= 45;
    psd_segment = Pxx(idx);
    
    % Compute metrics
    mean_psd = mean(signal);
    std_psd = std(signal);
    var_psd = var(signal);
    skewness_psd = skewness(signal);
    kurtosis_psd = kurtosis(signal);
   
    
  % Calculate the first derivative of the signal (X')
X_prime = diff(signal);

% Calculate Activity (F6)
Activity = var(signal);

% Calculate Mobility (F7)
Mobility = sqrt(var(X_prime) / var(signal));

% Calculate Complexity (F8)
% First calculate Mobility of the derivative signal (X')
Mobility_prime = sqrt(var(diff(X_prime)) / var(X_prime));

Complexity = Mobility_prime / Mobility;
    
    % Shannon Entropy(F9)
    % Normalize PSD values to get probabilities
psd_probs = psd_segment / sum(psd_segment);

% Compute Shannon entropy
shannon_entropy = -sum(psd_probs .* log(psd_probs));
    
    % Differential Entropy (F10)
    sigma = std(signal);

% Calculate the differential entropy 
differential_entropy = 0.5 * log(2 * pi * exp(1) * sigma^2);
    
 % Sample Entropy (F11)
   
m = 2;                        % Embedding dimension
r = 0.2 .* std(signal);     % Tolerance level (20% of standard deviation)
sampen_value = sampleEntropy(signal, m, r);
   
% Average band power using bandpower function (F12)
avg_band_power = bandpower(Pxx, f, 'psd');
    
% Store metrics
    metrics = [mean_psd, std_psd, var_psd, skewness_psd, kurtosis_psd, ...
               Activity, Mobility, Complexity, shannon_entropy, ...
               differential_entropy,sampen_value, avg_band_power];

end
