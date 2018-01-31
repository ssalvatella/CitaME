       *>
       *> VentanaPrincipal
       *>
       *> Clase de control de la ventana que usara
       *> la aplicación a lo largo de su ejecución.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 01/11/2017
       *>
       class-id CitaMe.vista.VentanaPrincipal is partial
                 inherits type System.Windows.Window.

       working-storage section.

       *> Implementa Singleton
       01 Instancia type CitaMe.vista.VentanaPrincipal static.

       01 BaseDatos type CitaMe.BaseDatos.
       01 CitaIniciada property type CitaMe.modelo.Cita.

       method-id NEW.
       procedure division.

           invoke self::InitializeComponent()

           *> Abrimos la conexión con la base de datos
           set BaseDatos to new CitaMe.BaseDatos().
           invoke BaseDatos::Conectar().

           set Instancia to self.
           goback.
       end method.

       *>
       *> CambiarFrame
       *>
       *> Cambia el contenido de la ventana cargando
       *> otra página
       *>
       method-id CambiarFrame.
       procedure division using by value url as string.

           set Contenido::Source to new System.Uri(url, type UriKind::Relative).
           goback.
       end method.

       *>
       *> DevuelveInstancia
       *>
       *> Devuelve la instancia de la ventana principal.
       *>
       method-id DevuelveInstancia static.
       procedure division returning inst as type CitaMe.vista.VentanaPrincipal.
           set inst to Instancia.
           goback.
       end method.

       *>
       *> EstablecerCitaIniciada
       *>
       *> Guarda la referencia a la cita abierta por el médico
       *> para su uso entre las vistas.
       *>
       method-id EstablecerCitaIniciada.
       procedure division using by value cita as type CitaMe.modelo.Cita.
           set CitaIniciada to cita.
           goback.
       end method.




       end class.
