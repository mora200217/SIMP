## I2C Master 
El protocolo de I2C depende de dos actores (Maestros y Esclavos). Para el caso puntual del proyecto usaremos un solo maestro y un solo esclavo.

### Máquina de estados 
El módulo consta de una (Finite State Machine) FSM de 7 estados. 

#### Eleccion de dispositivo
Una vez comenzado el proceso 



#### Lectura (READ)
- **Entrada al estado**: `read_write = 1` y haber definido previamente las direcciones de dispositivo y de registro a leer 
- **Salida del estado**: `bit_counter = 0` Cuando ya recorrió los 8 bits de lectura, comienza el proceso de ACK con el esclavo para continuar con la transacción.
- **Comentario**: La información queda guardada en `sda_out` y es la salida del modulo que usara el TOP para conocer la lectura por transacción para almacenarla en un registro. 

