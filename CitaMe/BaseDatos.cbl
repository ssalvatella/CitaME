       *>
       *> BaseDatos
       *>
       *> Clase que encapsula el m�todo para
       *> conectar con la base de datos correctamente.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificaci�n: 22/10/2017
       *>
       class-id CitaMe.BaseDatos.

       working-storage section.

       *> Habilita las variables de SQL
       exec sql 
           include sqlca 
       end-exec.

       01 mfsqlmessagetext pic x(355) values "".

       *> Datos de conexi�n
       01 usuarioBD values "root".
       01 contraseniaBD values "tzuqng".
       01 nombreBD values "CITAME".

       *>
       *> Conectar
       *> 
       *> Conecta con la base de datos mediante el OBCD definido 
       *>
       method-id Conectar.
       procedure division.

           *> En caso de cualquier error SQL
           exec sql
             whenever sqlerror
             go to ErrorSQL
           end-exec.

           *> Conectamos al DNS creado con el administrador de ODBC
           exec sql
               connect :usuarioBD identified by :contraseniaBD using :nombreBD
           end-exec.
           goback.

           *> Muestra error en una ventana de dialogo
           ErrorSQL.
               invoke type MessageBox::Show(mfsqlmessagetext, "Error - SQL", type MessageBoxButton::OK, type MessageBoxImage::Error).
           goback.
       end method.

       end class.

