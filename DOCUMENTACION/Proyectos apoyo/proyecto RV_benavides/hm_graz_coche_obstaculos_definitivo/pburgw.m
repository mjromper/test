function varargout= pburgw( x, p, nfft, ventana, Fs)
%PBURGW   Power Spectrum estimate via windowed-Burg method.
%   Pxx = PBURGW(X,ORDER,NFFT,WINDOW) is the Power Spectral Density estimate of  
%   signal vector X using the windowed-Burg method. ORDER is the order of the 
%   autoregressive (AR) model used to produce the PSD. NFFT is the FFT length
%   which determines the frequency grid. WINDOW is the Matlab window function
%   name we want to use for windowing the algorithm errors, e.g., 'boxcar' is
%   the same that use the classic pburg method, and 'hamming' is the solution
%   proposed by Swingler(For others possibilities, see reference).
%   Pxx is length (NFFT/2+1) for NFFT even, (NFFT+1)/2 for NFFT odd, and NFFT if
%   X is complex.  NFFT is optional; it defaults to 256.
%   When no window is specified, the algorithms use the boxcar one.
%   [Pxx,F] = PBURGW(X,ORDER,NFFT,WINDOW,Fs) returns a vector of frequencies at which
%   the PSD is estimated, where Fs is the sampling frequency.  Fs defaults to
%   2 Hz.
%
%   [Pxx,F,A] = PBURGW(X,ORDER,NFFT) returns the vector A of model coefficients
%   on which Pxx is based.
%
%   PBURG with no output arguments plots the PSD in the next available figure.
%
%   You can obtain a default parameter for NFFT and Fs by inserting an empty
%   matrix [], e.g., PBURGW(X,4,[],1000).
%   See also PBURG, PMEM, PMTM, PMUSIC, PSD, LPC, PRONY.

%	 Ref: J. G. Proakis y D. G. Manolakis, "Tratamiento Digital de Se�ales,
%			principios, algoritmos y aplicaciones", 1997, chapter 12.
%        (This book has several English versions)
%   Author(s): J. de la Torre Pel�ez
%   $Revision: 1.3 $  $Date: 2002/03/6 20:13:37 $
% SPANISH HELP AT THIS SCRIPT END.

%1 - Revisi�n de los par�metros de entrada/Input Parameters Revision--------------------------------------->>
error(nargchk(2,5,nargin));
if isempty(p),
   error('Model order is needed.');%Necesita indicar el orden del modelo
end;
if nargin < 5, Fs = [];   end  ;
if nargin < 4, ventana='boxcar'; end; %Ventana rectangular/Right-angled Window
if nargin < 3, nfft = []; end;
if isempty(nfft), nfft = 256; end;
if isempty(Fs), Fs = 2; end;

%2 - Inicializaci�n de los par�metros/Parameters Initialization-------------------------------------------->>
x  = x; 
N  = length(x);
fi_t = x(2:end);%Vector truncado de errores de predicci�n hacia adelante/Forward prediction errors truncated vector
gi_t = x(1:end-1);%Vector truncado de errores de predicci�n hacia atr�s/Backward prediction errors truncated vector
a  = 1;%Inicializaci�n del vector de estimas de los coeficientes {ak} del filtro AR/ {ak}=AR filter coefficientes vector initialization
	Epsilon = x*x'/N; %(Epsilon0)(Error de m�n. cuadrados)/(Min. square error)
K = zeros(p,1); %Estima de los coeficientes de reflexi�n/Reflection coefficients Estimate

%3 - C�lculo de las estimas de K, E, {ak}/ K, E {ak} Evaluation-------------------------------------------->>
%-----Procedimiento Iterativo/Iterative Algorithm---------------------------------------------------------->>
for i=1:p,
   %C�lculo de la ventana/Window evaluation:
   %Haci�ndolo como sigue, puedo usar cualquier ventana que este
   %implementada como una funci�n Matlab:
   %Using this way, I can use whatever function I want, if it is built with Matlab:
   vent=['v=' ventana '(length(fi_t));'];
   eval(vent);
   v=v(:)'; %Para convertirlo a fila(tanto si era columna como fila)/Convert to row.

   K(i)=-((v.*fi_t)*gi_t')/(((v.*fi_t) * fi_t'  +  (v.*gi_t) * gi_t')/2);%Con ventana/Using window
   %K(i)=-(fi_t*gi_t')/((fi_t * fi_t'  +  gi_t * gi_t')/2); %Sin ventana(=con ventana cuadrada)/No Window(=Rectangular window)
   
   a = [a;0] + K(i) * [0;flipud(conj(a))]; %Actualizaci�n de los {ak} / {ak} Actualization
   
   fi_t_nuevo= 		  fi_t	+	K(i) * gi_t;
   gi_t_nuevo= K(i)' * fi_t  +			 gi_t;
   fi_t= fi_t_nuevo(2:end);
   gi_t= gi_t_nuevo(1:end-1);
   
   Epsilon(i+1) = (1-K(i)*K(i)')*Epsilon(i);%error de m�n. cuadrados/min. square error
end; %for i=1:p-1,
%-----------------------------<<------------Fin del procedimiento Iterativo/Iterative Algorithm ends here.

%4 - Estimaci�n de la DEP usando la FFT(periodograma)/PSD Estimation using FFT(periodogram)---------------->>
Af = abs( fft( a, nfft ) ) .^ 2; %Funci�n de trasferencia del denominador del filtro/Filter denominator Transfer Function
Pxx   = Epsilon(end) ./ Af; %Funci�n de trasferencia teniendo en cuenta la entrada(ruido)/Transfer Function including noise

%5 - Control de la salida/Output Control------------------------------------------------------------------->>
%Si la entrada es real, se selecciona s�lo la primera mitad/If entry is real, we get only first half:
if isreal(x),
   select = (1:floor(nfft/2)+1)';%Siempre es unilateral(Solo frecuencias positivas)/Always is onesided(only positive frequencies)
   Pxx = Pxx(select);
   %Para que sea unilateral hay que hacer una correcci�n/To be onesided, we must made a correction:
   Pxx(1)=Pxx(1)/2;
   Pxx(end)=Pxx(end)/2;
else,
   select = (1:nfft)';
   Pxx = Pxx(select);
end;

ff = (select - 1)*Fs/nfft;

%Argumentos de salida/Output arguments:
if nargout == 0,
   newplot;
   plot(ff,10*log10(Pxx)); grid on;
   xlabel('Frequency');
   ylabel('Power Spectrum Magnitude (dB)');%(M�dulo de la D.E.P.[dB])
   title('Burg Spectral Estimate');%(Estimaci�n Espectral de Burg)
end;
if nargout >= 1,
   varargout{1} = Pxx;
end;
if nargout >= 2,
   varargout{2} = ff;
end;

%VERSI�N ESPA�OLA DE LA AYUDA:
%PBURGW   Estimaci�n Espectral de Potencia usando Burg con enventanados
%   Pxx = PBURGW(x,ORDEN,NFFT,VENTANA) es la estimaci�n de la D.E.P.(Densidad
%	 Espectral de Potencia) de la se�al x, usando el m�todo de Burg con 
%	 enventanado. ORDEN es el orden del modelo AR de predicci�n lineal.
%	 NFFT es la longitud de la FFT que determina las frecuencias a que se
%	 estima la D.E.P. VENTANA es el nombre de la funci�n Matlab que realiza
%	 una determinada ventana, por ejemplo 'boxcar'(equivaldr�a al m�todo de
%	 Burg b�sico), o 'hamming' empleado por Swingler. 
%	 Pxx tendr� longitud (NFFT/2+1) para NFFT par, (NFFT+1)/2 para NFFT impar,
%	 y NFFT si x es una se�al compleja. NFFT es un par�metro opcional que por
%	 defecto vale 256.
%	 Si no se especifica la ventana, se sobrentiende que se usa la ventana
%	 rectangular(boxcar). 
%
%   [Pxx,F] = PBURGW(X,ORDER,NFFT,ventana,Fs) devuelve adem�s, el vector de
%	 frecuencias en que se eval�a la D.E.P., para una frecuencia de muestreo Fs.
%	 Por defecto Fs vale 2Hz, que equivaldr�a a usar un vector de frecuencias
%	 normalizadas.
%
%   PBURGW sin argumentos de salida dibuja la DEP en la siguiente figura disponible.
%
%	 Puede usarse el par�metro NFFT por defecto, indic�ndolo como una matriz
%	 vac�a [], ej. PBURGW(X,4,[],1000).
%
%   Vea tambi�n PBURG, PMEM, PMTM, PMUSIC, PSD, LPC, PRONY.

