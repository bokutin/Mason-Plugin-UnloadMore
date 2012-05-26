package Mason::Plugin::UnloadMore::Compilation;

use Mason::PluginRole;

around output_class_footer => sub {
    my $orig = shift;
    my $self = shift;

    return join("\n",
        $self->$orig(@_),

        # 1クラス(.mc)あたり、約12.020k節約できる。
        'Mason::Interp->current_load_interp->component_import_class->unimport;',
        'Mason::Interp->current_load_interp->component_moose_class->unimport;',
    );
};

1;
