       *>
       *> Admin
       *>
       *> Clase de control de la vista de
       *> inicio para el administrador.
       *>
       *> Autor: Samuel Salvatella
       *> Ultima modificación: 20/12/2017
       *>
       class-id CitaMe.vista.Admin is partial
                 inherits type System.Windows.Controls.Page.

       working-storage section.

       01 vtnPrincipal type CitaMe.vista.VentanaPrincipal.
       01 modeloUsuario type CitaMe.modelo.Usuario.
       01 registradosRecientes type List[type CitaMe.modelo.Usuario].

       method-id NEW.
       local-storage section.
       procedure division.
           invoke self::InitializeComponent().
           *> Guardamos la referencia a la ventana principal
           set vtnPrincipal to type CitaMe.vista.VentanaPrincipal::DevuelveInstancia().
           *> Cargamos el modelo de usuarios para consultarlo
           set modeloUsuario to new CitaMe.modelo.Usuario().
           *> Obtenemos los usuarios registrados recientemente
           set registradosRecientes to modeloUsuario::UltimosRegistrados().
           *> Ponemos los usuarios obtenidos en la tabla
           perform varying usuario as type CitaMe.modelo.Usuario through registradosRecientes
               invoke tablaUsuariosRegistrados::Items::Add(usuario)
           end-perform.
           goback.
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
       *> BotonIrUsuarios
       *>
       *> Carga la vista para ver los usuarios
       *>
       method-id BotonIrUsuarios final private.
       procedure division using by value sender as object e as type System.Windows.RoutedEventArgs.
          invoke vtnPrincipal::CambiarFrame("/vista/admin/AdminUsuarios.xaml").
          goback.
       end method.


       end class.
