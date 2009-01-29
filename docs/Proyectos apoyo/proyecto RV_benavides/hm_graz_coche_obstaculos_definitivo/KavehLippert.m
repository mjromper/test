function wmk = KavehLippert(n_points)
%KAVEHLIPPERT Kaveh-Lippert window.
%   wmk = KAVEHLIPPERT(n_points) returns the n_points=(N-m) point Kaveh-Lippert
%         window. where 'N' is the length of the original signal, and 'm' is 
%         refered to the mth PARCOR of the Optimum Tapered Burg Algorithm.
%
%   EXAMPLE(refered to its APPLICATION):
%         Fs=128; orden=8;Kavehlippert generally works better with a big order.
%         n_points=512;
%         t=(0:24)*1/Fs;   phase=pi-1.9999*pi*rand(1);   noise=.4*randn(1,length(t));
%         x= sin(2*pi*10*t + phase) + noise;
%         pxx1=pburg(x,orden,n_points,Fs,'onesided');
%         pxx2=pburgw(x,orden,n_points,'kavehlippert',Fs);
%         plot(pxx1); plot(pxx2,':r');
%
%   See also BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, BOHMANWIN, CHEBWIN, 
%            GAUSSWIN, HAMMING, HANN, KAISER, NUTTALLWIN, RECTWIN, TRIANG, 
%            TUKEYWIN, WINDOW, pburgw.

%   Reference:
%     [1] Mostafa Kaveh, and George A. Lippert, "An Optimum Tapered Burg
%         Algorithm for Linear Prediction and Spectral Analysis", IEEE
%         Transactions on Acoustics, Speech, and Signal Processing,
%         Vol. ASSP-31, No. 2, April 1983
%     [2] J. G. Proakis y D. G. Manolakis, "Tratamiento Digital de Señales,
%         principios, algoritmos y aplicaciones", 1997, chapter 12.
%         (This book has several English versions)

%   Copyright 2002 by Juan de la Torre Peláez
%                     DTE - Universidad de Málaga
%   $Revision: 1.1 $  $Date: 2002/05/10 12:26:30 $

error(nargchk(1,2,nargin));

% Default value for order m:
if nargin < 2 | isempty(m), 
    m = 1;
end

%Originally proposed by Kaveh[1]:
%k=0:N-m-1;
%wmk=6*(k+1).*(N-m-k+1) / ((N-m+1)*(N-m+2)*(N-m+3));

%Adaptation for using with pburgw.m, based on [2]:
k=0:n_points-1;
wmk=6*(k+1).*((n_points-1)-k+1) / (((n_points-1)+1)*((n_points-1)+2)*((n_points-1)+3));

wmk=wmk(:)'; %convert to row

%This window is used for tapering the forward and backward error
%energies in the estimation of the mth PARCOR(Partial Correlation
%coefficients) in the Windowed Burg Method. The target looked by 
%Kaveh was designing an optimum taper for the Windowed Burg Method,
%by minimizing this method's frequency error for a sinusoid without
%noise. Although this, the method generally works better than classic
%Burgrg for any signal. The Windowed Burg Method idea was first 
%suggested by Swingler who proposed the use of the Hamming window.
%Kaveh called his method the TBO(Optimum Tapered Burg). You can use
%the TBO algorithm, simply getting the pburgw.m method(you can find it
%in the same way you got this kaveh.m algorithm in www.Mathworks.com,
%or ask me for it, free of course: juandelatorre@gsmbox.es)

%Esta ventana se utiliza para ponderar la energia de los errores
%hacia delante y atras de la estimacion del m-esimo coeficiente
%de reflexion de Estimacion Espectral Parametrica de Burg Enventanado.
%El objetivo buscado por Kaveh, era diseñar un ventana de ponderacion
%optima para dicho Metodo, minimizando el error de frecuencia para 
%una sinusoide sin ruido. A pesar de esto, el metodo funciona mejor que
%el clasico de Burg para cualquier señal en general. La idea del Metodo
%de Burg Enventanado fue sugerida por primera vez por Swingler que 
%propuso el uso de la ventana de Hamming.
%Kaveh llamo a su metodo el TBO(Optimum Tapered Burg). Puedes utilizar
%el TBO, simplemente obteniendo el algoritmo pburgw.m(puedes encontrarlo
%de la misma forma que encontraste este algoritmo en www.Mathworks.com,
%o pidemelo a mi, y te lo regalo: juandelatorre@gsmbox.es)
