package Points;
use Modern::Perl;
use Time::HiRes qw/time/;

our $g = 9.8;
our $id = 0;

sub new
{
	my $class = shift;
	my $ref = 
        {
            id => $id++ ,
            time => time() ,
            timeply => 1.0,             #时间倍率
               xs => 10.0 + rand(5.0) ,
            ys => 15.0 + rand(10.0) ,
            zs => 15.0 + rand(10.0) ,
            @_ ,
        };
        
	bless $ref, $class;
    return $ref;
}

sub show_info
{
    my $self = shift;
    printf "%.2f %.2f %.3f\n", $self->{x}, $self->{y}, $self->{time};
}

sub curr_pos
{
    my $self = shift;
    # 速度分量
    my ($vx, $vy, $vz) = ( $self->{xs}, $self->{ys}, $self->{zs} );
    my ($x, $y, $z);

    # 时间差 * 2
    my $t = ( time() - $self->{time} ) * $self->{timeply};

    # y = V0t - 1/2 * gt^2
    $x = $self->{x} + $vx * $t;
    $y = $self->{y} + $vy * $t - $g /2.0* $t * $t;
    $z = $self->{z} + $vz * $t;

    return ( $x, $y, $z );
}

1;