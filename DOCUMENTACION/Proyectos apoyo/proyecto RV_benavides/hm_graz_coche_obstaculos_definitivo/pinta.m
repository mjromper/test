Fs=130;
for i=9:14,
   clear s1;
   comando=['load v' , num2str(i) , '.mat s1'];  
   eval(comando);
   figure;
   %t=(4+1/Fs):1/Fs:(4+.5*(i-8));   plot(t,s1(end-length(t)+1:end));
   P=pburg(s1(end+1-65:end),6,520,130,'onesided');
   res=Fs/520; f=0:res:Fs/2;
   plot(f,P);
   
end;