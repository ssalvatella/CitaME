      $set sourceformat(variable)

      *> Namespace: CitaMe.Properties

       class-id CitaMe.Properties.Settings is partial is final inherits type System.Configuration.ApplicationSettingsBase
           attribute System.Runtime.CompilerServices.CompilerGenerated()
           attribute System.CodeDom.Compiler.GeneratedCode("Microsoft.VisualStudio.Editors.SettingsDesigner.SettingsSingleFileGenerator", "15.3.0.0")
       .

       working-storage section.
       01 defaultInstance type CitaMe.Properties.Settings value type System.Configuration.ApplicationSettingsBase::Synchronized(new CitaMe.Properties.Settings) as type CitaMe.Properties.Settings static.

       method-id get property Default static final.
       procedure division returning return-item as type CitaMe.Properties.Settings.
       set return-item to defaultInstance
       goback
       end method.

       end class.
