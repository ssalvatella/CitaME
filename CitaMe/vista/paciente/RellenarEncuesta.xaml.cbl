

       *>
       *> RellenarEncuesta
       *>
       *> Clase de control de la vista para
       *> completar encuestas.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 27/01/2018
       *>
       class-id CitaMe.vista.paciente.RellenarEncuesta is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.
       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       method-id NEW.
       procedure division.
           invoke self::InitializeComponent()
           *> Guardamos la referencia a la ventana principal
            set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().
           goback.
       end method.



       *>
       *> BotonCompletarEncuesta
       *>
       *> Registra los datos de la encuesta
       *>
       method-id BotonCompletarEncuesta final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/paciente/Paciente.xaml").
          goback.
       end method.


       end class.
