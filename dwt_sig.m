function out = dwt_sig(sig, fs)
    
    
    [C, L] = wavedec(sig, 4, "db4"); % Decompose signal using wavelet
    
    % Reconstruct the different EEG bands using wrcoef
    out.delta = wrcoef('a', C, L, 'db4', 4);   %  Delta 
    out.theta = wrcoef('d', C, L, 'db4', 4);   % Theta 
    out.alpha = wrcoef('d', C, L, 'db4', 3);   % Alpha 
    out.beta  = wrcoef('d', C, L, 'db4', 2);   % Beta 
    out.gamma = wrcoef('d', C, L, 'db4', 1);   % Gamma 
end

