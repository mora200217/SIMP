# SIMP
Sistema Inteligente de Monitoreo de Postura 

## Modulos 
- I2C Master Module: Encargado del protocolo I2C para la lectura de de datos de la IMU BMI160


### I2C Master Module: 
Se empleará un protocolo I2C de 8 bits de data con 7 bits de registro / dispotivio. De tipo Single Master Single Slave, para simplificar la implementación, y debido a que solo usaremos una FPGA (master) y una IMU de datos (slave). 

Por protocolo, se usará SCL y SDA como salidas principales (Con la excepción que el SDA es bidireccional )

Basados en la documentación de la IMU BMI160, se encontró que la direccion de dispositivo es 0x68 por defecto. Para la extracción de datos de aceleracion tenemos las siguientes direcciones 

> Todo dato de lectura tiene una resolucion de 16 bits. Por transacción se envía un paquete de 8 bits, por lo que cada variable tendrá dos paquetes (LSB y MSB)

- **AccX** [LSB: 0x12, MSB: 0x13]
- **AccY** [LSB: 0x14, MSB: 0x15]
- **AccZ** [LSB: 0x16, MSB: 0x17]

Para que le modulo funcione, debe ser activado por una señal *enable*. Una vez iniciado, se procede a la máquina de estados. 

#### Máquina de estados 
Una de las principales señales en el protocolo, es el **enable**. Este permite iniciar con el proceso de transacción. Este proceso se divide en 3 partes. 



