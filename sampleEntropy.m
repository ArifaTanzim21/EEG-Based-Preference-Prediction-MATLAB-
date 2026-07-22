function sampen = sampleEntropy(signal, m, r)
    % signal: Input time series (EEG data, for example)
    % m: Embedding dimension (commonly 2)
    % r: Tolerance (commonly 0.2 * std(signal))
    
    N = length(signal);
    % Calculate standard deviation and tolerance
    tol = r * std(signal);
    
    % Precompute the m and m+1 subsequences
    X_m = zeros(N-m, m);
    X_m1 = zeros(N-m, m+1);
    
    for i = 1:N-m
        X_m(i,:) = signal(i:i+m-1);
        X_m1(i,:) = signal(i:i+m); % for m+1 subsequence
    end
    
    % Calculate distance matrix for dimension m
    D_m = squareform(pdist(X_m, 'chebychev'));
    Bm = sum(D_m < tol, 'all') - N + m;
    
    % Calculate distance matrix for dimension m+1
    D_m1 = squareform(pdist(X_m1, 'chebychev'));
    Bm1 = sum(D_m1 < tol, 'all') - N + m + 1;
    
    % Compute Sample Entropy
    if Bm == 0
        sampen = inf;
    else
        sampen = -log(Bm1 / Bm);
    end
end
