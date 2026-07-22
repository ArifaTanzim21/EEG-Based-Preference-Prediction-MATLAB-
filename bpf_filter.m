function out=bpf_filter(sig,fs)


[b,c]=butter(2,[4 8]/(fs/2))     
out.theta=filter(b,c,sig)

[b,c]=butter(2,[8 13]/(fs/2))
out.alpha=filter(b,c,sig)


[b,c]=butter(2,[13 30]/(fs/2))
out.beta=filter(b,c,sig)


[b,c]=butter(2,[30 ((fs/2)-5)]/(fs/2))
out.gamma=filter(b,c,sig)


end

