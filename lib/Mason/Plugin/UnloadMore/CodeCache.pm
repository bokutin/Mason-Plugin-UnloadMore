package Mason::Plugin::UnloadMore::CodeCache;

use Mason::PluginRole;

use Devel::GlobalDestruction;

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
        Class::MOP::remove_metaclass_by_name($compc);

        #Method::Signatures::Simple
        Devel::Declare->teardown_for($compc);

        #Moose::Meta::TypeConstraint::Class
        delete Moose::Util::TypeConstraints::get_type_constraint_registry()->type_constraints->{$compc};
    }

    $ret;
};

1;
