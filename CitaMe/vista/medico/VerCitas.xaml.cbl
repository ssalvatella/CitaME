       *>
       *> VerCitas
       *>
       *> Clase de control de la vista que
       *> muestra el histórico de citas del médico.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 20/01/2018
       *>
       class-id CitaMe.vista.medico.VerCitas is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       01 modeloCita type CitaMe.modelo.Cita.

       method-id NEW.
       procedure division.
           invoke self::InitializeComponent()
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia()
           set modeloCita to new CitaMe.modelo.Cita()
           invoke MostrarCitas()
           goback.
       end method.

       *>
       *> MostrarCitas
       *>
       *> Carga la tabla con todas las citas en orden
       *> de fecha descendente.
       *>
       method-id MostrarCitas final private.
       01 citas List[type CitaMe.modelo.Cita].
       procedure division.
           *> Obtenemos las citas
           set citas to modeloCita::DevuelveCitasMedico(type CitaMe.vista.Login::idUsuario, False).
           invoke tablaCitas::Items::Clear().
           *> Ponemos los usuarios obtenidos en la tabla
           perform varying cita as type CitaMe.modelo.Cita through citas
               invoke tablaCitas::Items::Add(cita)
           end-perform.

       end method.

       *>
       *> BotonSalir
       *>
       *> Carga la vista al Login
       *>
       method-id BotonSalir final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/Login.xaml").
          goback.
       end method.

       *>
       *> BotonIrCitas
       *>
       *> Carga la vista para ver las citas
       *>
       method-id BotonIrCitas final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/Medico/VerCitas.xaml").
          goback.
       end method.

       *>
       *> BotonIrInicio
       *>
       *> Carga la vista de inicio del médico
       *>
       method-id BotonIrInicio final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/medico/Medico.xaml")
          goback.
       end method.


       end class.
