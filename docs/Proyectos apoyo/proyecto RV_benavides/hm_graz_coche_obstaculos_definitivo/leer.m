Esto pretende ser un breve resumen de como manejar el BCI de Graz


---------------------------------IMPORTANTE------------------------------------------
---------------------------------IMPORTANTE------------------------------------------
   
   1- Si se puede hacer hacer que la Frecuencia vaya a 128 Hz, de hecho es recomendable porque el gBSanalyze no 
   hace bien el MERGE si la frecuencia es distinta.
   
        Para ello los PARAMETROS deben ser los siguientes
            Fs=128Hz
            Tam_ventana=4
            t.objetivo=3
            t_analisis=4.25
            Duracion=3.75
            Duracion prueba=8   (a lo mejor hay que dejar 8.5 para que no este tan ajustado en tiempo cuando se
                            haga el analisis con gBsanalyze, al hacer el trigger. Incluso 9s y entonces el 
                            Descanso entre prueba podria ser: 1    0.5 , para compensar)
            Descanso entre prueba 2    0.5
            Se deben hacer 40 pruebas
    
    
    
    
    2-  Para el feedback continuo podria configurar Tam_ventana=2, eso significa que la barra se actualizara
    64 veces por segundo, pero esto da tiempo si no visualizo ni fig_tiempo ni fig_frecuencia. Para evitar problemas
    es preferible que Tam_ventana=4.
    
    3-  si no cumplo con estos parametros tengo que tener cuidado con las variables declaradas en Ensayo
    que son:
        
            bloq_seg=Fs/tam_ventana;
            bloque_analisis=t_analisis*bloq_seg; %NV
            bloque_dur_ana=d_analisis*bloq_seg;
            bloque_objetivo=t_objetivo*bloq_seg; %
            bloque_cursor=t_cursor*bloq_seg;
            bloque_beep=2*bloq_seg;  %NV ES EL BEEP DEL PARADIGMA DE GRAZ A LOS DOS SEGUNDOS
            %bloque_fin_CUE=4.2*bloq_seg; %esto  es para Fs=130 y tam =26 o 13
            bloque_fin_CUE=4.25*bloq_seg; %esto  es para Fs=128 y tam =4 
            
      porque podrian no ser numeros enteros, y deben ser enteros.
      
   
      5- He introducido configuraciones rapidas:

    * N-F: 40 pruebas sin feedback
    * F-D: 40 pruebas con feedback discreo (ahora mismo no esta operativo)
    * F-C: 40 pruebas con feedback continuo   
    ---------------------------------IMPORTANTE------------------------------------------
   ---------------------------------IMPORTANTE------------------------------------------
   
   
6- OPCION con FS=130Hz.(NO DESEABLE porque gBSanalyze no lo admite)
La frecuencia de muestreo deberia ser de 130Hz, de lo contrario es muy dificil hacer particiones de la
frecuencia de 128 Hz. Este cambio de frecuencia no afecta para nada.

t_objetivo es el instante en que aparece la flecha y debe ser 3 segundos

El control de los tiempos del CUE lo voy a hacerlo con una variable que cuenta los bloques, y para 
que funcione bien, el tama�o de la ventana debe ser de un maximo de 20ms, es decir 26 muestras, 
on en su caso 13 muestras.
Si no lo hago asi, no funcionara bien, y debere controlar este CUE por tiempos. Segun Graz, el CUE, que 
es la flecha, debe desaparecer a los 4,25 sesundos, yo lo voy a hacer a los 4,2 segundos, definiendo en
ensayo, una variable llamada bloque_fin_CUE=4.2*bloq_seg, es decir el bloque 21.


    Los parametros a introducir deben ser:
    Fs=130Hz
    Tam_ventana=26
    t.objetivo=3
    t_analisis=4.2
    Duracion=3.8
    Duracion prueba=8   (a lo mejor hay que dejar 8.5 para que no este tan ajustado en tiempo cuando se
                         haga el analisis con gBsanalyze, al hacer el trigger)
    Descanso entre prueba 2    0.5
    Se deben hacer 40 pruebas
    

  
    He introducido configuraciones rapidas:

 * N-F: 40 pruebas sin feedback
 * F-D: 40 pruebas con feedback discreo (ahora mismo no esta operativo)
 * F-C: 40 pruebas con feedback continuo