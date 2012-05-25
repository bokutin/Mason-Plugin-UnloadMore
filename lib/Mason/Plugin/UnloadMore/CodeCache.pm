package Mason::Plugin::UnloadMore::CodeCache;

use Mason::PluginRole;

use Devel::GlobalDestruction;
use Symbol ();

around remove => sub {
    my $orig = shift;
    my $self = shift;
    my $key  = shift;

    my $compc;

    if ( my $entry = $self->{datastore}->{$key} ) {
        if ( !in_global_destruction() ) {
            $compc = $entry->{compc};
        }
    }

    my $ret = $self->$orig($key,@_);

    if ( !in_global_destruction() ) {
        #Moose::Meta::Class                      0     20     20
        #Moose::Meta::Instance                   0     20     20
        #Moose::Meta::Method::Augmented          0     20     20
        #Moose::Meta::Method::Meta               0     20     20
        _unload_class($compc);

        #Method::Signatures::Simple
        Devel::Declare->teardown_for($compc);

        #Moose::Meta::TypeConstraint::Class
        delete Moose::Util::TypeConstraints::get_type_constraint_registry()->type_constraints->{$compc};

        # free memory
        Symbol::delete_package($compc);
    }

    $ret;
};

# http://cpansearch.perl.org/src/DOY/Moose-2.0602/t/type_constraints/name_conflicts.t
sub _unload_class {
    my ($class) = @_;
    my $meta = Class::MOP::class_of($class);
    return unless $meta;
    $meta->add_package_symbol('@ISA', []);
    $meta->remove_package_symbol('&'.$_)
        for $meta->list_all_package_symbols('CODE');
    undef $meta;
    Class::MOP::remove_metaclass_by_name($class);
}

1;
