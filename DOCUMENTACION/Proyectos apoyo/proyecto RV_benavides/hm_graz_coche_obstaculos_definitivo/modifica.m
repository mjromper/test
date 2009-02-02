CAMBIOS IMPORTANTES

    - Medir:
        Utilizo la tarjeta de sonido. He quitado la DAQ
      
        
    -Prueba: 
    
        La muestra 1 la multiplico por 10 para que se vea algo
        La tarjeta de sonido solo trabaja con dos canales, por lo que las muestras 3 y 4 las he cambiado,
        y lo que le pido es que vuelva a capturar los canales 1 y 2. Esto afecta a:
        
        muestra3(inicio : inicio + tambloque-1)= d(:,1); %muestra3 es el canal 3
	    muestra4(inicio : inicio + tambloque-1)= d(:,2); %muestra4 es el canal 4
        muestratotal3(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,1); %muestra3 es el canal 3
	    muestratotal4(inicio_ensayo : inicio_ensayo + tambloque-1)= d(:,2); %muestra4 es el canal 4
        
        
     - Aunque en HM_PANEL he introducido el mundo, yo creo que es solo a partir de Medir
     que realmente debo hacer cambio.Anteriormente a esto no es del todo necesario, pues 
     aunque se prpara la figura de juego, a partir de Medir lo que debo hacer es no actualizar dicha
     medida y trabajar con el mundo virtual.
     
     -La instruccion "if str2num(tipologia(pruebactual))==6" del programa tiempo2frec, es el encargado de llamar 
         a DESCURSOR que es el encargado de desplazar el cursor. Esta llama dolo se hace con la opcion
         "jugar" y esto habra que tenerlo en cuenta por si se quiere desplazar en otros casos.
         
     -He tratado de suprimir todo lo referente a la figura del sujeto, llamada "figure(fig_sujeto)". 
     Esto afecta en gran parte al HM-panel donde se encargaba de configurar adecuadamente la pantalla, 
     pero tambien afecta a ENSAYO.m pues en ese prgrama se suprimen los cursores que aparecian en la
     figura para su correcta adaptacion.
    
     -En el programa present.m tambien hay algunas lineas relativas a la figura del sujeto. Tambien las 
     he suprimido. Son las lineas que dibujaban los ejes y el cursor en el centro de color negro.
     - Debo tener cuidado porque en esas instrucciones se definia la variable 'p', que determina 
     la posicion del cursor. Esta variable p podria ser la posicion del objeto en el mundo virtual.
     
     
     - Modificacion importante en Prueba.m:
     El programa original HM siempre procesaba las 4 se�ales, y para ello llamaba a la funcion "tiempo2frec.m".
     La modificacion que propongo es la de introducir una variable que se llame "num_canales_procesar", en la que
     se indicara cuantos cana les quiero procesar. Capturar se seguiran capturando todos los canales, y se grabaran 
     aquellos que se seleccionen, pero ademas introduzco la posibilidad de procesar un numero determinado de canales
     y no todos. EL orden de canales a procesar siempre es el mismo, es decir se empieza por el primero hasta llegar 
     al cuarto. Esta variable la voy a definir en el programa principal HM_panel.m, y por defecto la voy a dejar como uno.
     Segun el valor de esa variable "num_canales_procesar", el programa Prueba.m llamara a 4 funciones diferentes , 
     dependiendo del numero de canales a procesar. Esta llamada de funciones es:

     
     <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
     if (tiempo1>t_analisis+tambloque/Fs) & (tiempo1<=t_analisis+d_analisis+retardo), %usar tiempo2frec antes no merece la pena
    %tiempo2frec(muestra1,muestra2,muestra3,muestra4,inicio); %EL ERROR divide by cero, lo da en estos programas
    if num_canales_procesar==1, tiempo2frec_1c(muestra1,inicio); end; %NV PROCESO EL CANAL UNO
    if num_canales_procesar==2, tiempo2frec_2c(muestra1,muestra2,inicio); end; %NV PROCESO EL CANAL UNO y DOS
    if num_canales_procesar==3, tiempo2frec_3c(muestra1,muestra2,muestra3,inicio); end; %NV PROCESO EL CANAL UNO, DOS Y TRES
    if num_canales_procesar==4, tiempo2frec_4cb(muestra1,muestra2,muestra3,muestra4,inicio); end; %NV PROCESO EL CANAL UNO, DOS, TRES Y CUATRO
    
     end;
     <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
     
      Al llamar a 4 funciones diferentes, lo unico que debe diferenciar cada funcion es el numero de canales
      a procesar, pero el resto debe ser igual. Esto significa que cualquier modificacion que haga debe ser la 
      misma para las 4 funciones.
      
      - A estas funciones, versiones de "tiempo2frec", he quitado lo de almacenar el resultado del procesado,
      porque me consumia mucha memoria pero sobre todo mucho tiempo.
      
      
      
      - En el programa HM-panel, he moificado la linea:
        cell_metodosEE={'/FFT/' 'Periodograma' 'Burg' 'Covarianza' 'BurgW-KL'}, por:
        cell_metodosEE={'/FFT/' 'Periodograma' 'Burg' 'Covarianza' 'potencia'},
        
        donde he cambiado el ultimo metodo por el de potencia. 
        Esto afecta a todos los programas "tiempo2frec_?c", donde el "case 5", calculo ahora la 
        potencia de la se�al.
        
        
        - En el programa HM_PANEL he configurado la pantalla de representacion temporal como toda 
        la pantalla completa, y en el programa PRESENT.M la pongo en su forma original (media pantalla)
        en caso de querer expresar tambien la respuesta frecuencial o la potencia.
        
        -IMPORTANTE: Para que al dibujar tanto la repuesta temporal y potencia de los canales, y
        que estos no esten superpuestos, lo unico que debo hacer es sumar un offset para cada canal justo
        al hacer el plot. Esto no lo hago ahora, y lo dejare para el final porque debo ajustar el eje X.
        Para esto se puede usar la funcion axis
        
        - IMPORTANTE: PARA COMPROBAR QUE UN PROCESO VA EN TIEMPO REAL SE DEBE VISUALIZAR EL NUMERO DEL BLOQUE 
        QUE SE ESTA PROCESANDO Y VISUALIZAR UNA EL TIEMPO QUE TARDA EN HACERSE EL PROCESO. PARA ELLO HAY QUE 
        QUITAR EL ; EN EL COMANDO n_de_bloque = n_de_bloque + 1 DEL PRUEBA.M (linea 186) Y CREAR ESA VARIABLE DE 
        TIEMPO: YO LA HE LLAMADO  tiempoB=toc-tiniburg(indice+1) Y LA HE PUESTO EN EL PROGRAAM TIEMPO2FREC_4 (linea 414)
        
        
        -Otra forma de poder ganar tiempo es  no grabando todos los rti.mat, o al menos lo de los filtros.
        Estoy hablando de suprimir todo el punto 6 del programa prueba.m
        
        -He modificado el programa Present.m para hacer la comprobacion de la altitud de la bola. Esa variable 
        con la altitud la he llamado alt.
        
        
        -CUIDADO:POSIBLE ERROR.
         ME DOY CUENTA QUE LA COMPROBACION DE LA ALTITUD LA HAGO AL FINAL DE LA
        PRUEBA, PERO SI SUPERO EL UMBRAL Y LUEGO VUELVO A ESTAR POR DEBAJO DE EL,
        AL COMPROBAR AL FINAL DE LA PRUEBA NO LO VOY A CONSIDERAR COMO EXITO. ESTO
        HAY QUE TENERLO EN CUENTA
        
        
        - Un problema en el plot de las se�ales EEG era que las diferentes tramas no se conectaban, por lo que
        habia un hueco. Lo he arreglado introduciendo en el programa prueba.m las variables :persistent ti d1 d2 d3 d4
        que lo que hace es almacenar la ultima muestra de la trama entrior, y asi en el plot de cada trana la utilizo
        para hacer el conexionado.
        

        - Voy a introducir un canal mas pero solo va a ser para capturar la se�al y no para procesar. Esto va a afectar 
        a Medir y a Prueba y en algunas variables en HM_PANEL que son COLOR_C5 y grabar_c5 la cual se debe
        inicializar a 1 si se quiere capturar ese canal.
        
        - He introducido la posibilidad de dibujar o no los canales que si se quieren grabar e incluso
        aquellos que son filtados. Esas variables deben cambiarse en HM-PANEL y son:
             global perm_plot_c1 perm_plot_c2 perm_plot_c3 perm_plot_c4 perm_plot_c5
               global perm_plot_prc1 perm_plot_prc2 perm_plot_prc3 perm_plot_prc4
               
        - DOY LA POSIBILIDAD DE NO REPRESENTAR LA fig_tiempo EN NINGUN MOMENTO, Y ESTO ES UTIL PARA TRABAJAR
        CON EL PORTATIL. PARA ELLO SE DEBE DECLARAR LA VARIABLE no_portatil EN HM_PANEL COMO:
                no_portatil=0  
          Y DEBO TENER CUIDADO DE DESACTIVAR LA REPRESENTACION DE LA FIGURA TIEMPO EN EL PANEL DE CONTROL.    
          
          
        - Doy la posibilidad de una representacion temporal larga, deforma que el eje de tiempo  sea de 
        una longitud definida por eje_tiempo. Para ello debo poner la variable aquisic_normal=0 y es necesario 
        que no_portatil=1, y definir una unica prueba.

            
        
        

     
     
     
    
    
    