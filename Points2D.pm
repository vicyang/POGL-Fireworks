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
            timeply => 2.0,             #时间倍率
            xs => 10.0 + rand(5.0) ,
            ys => 15.0 + rand(10.0) ,
            @_ ,
        };
        
    $ref->{prvx} = $ref->{x};
    $ref->{prvy} = $ref->{y};
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
    my ($vx, $vy) = ( $self->{xs}, $self->{ys} );
    my ($x, $y, $prvx, $prvy);
    $prvx = $self->{prvx};
    $prvy = $self->{prvy};

    # 时间差 * 2
    my $t = ( time() - $self->{time} ) * $self->{timeply};

    # y = V0t - 1/2 * gt^2
    $x = $self->{x} + $vx * $t;
    $y = $self->{y} + $vy * $t - $g /2.0* $t * $t;

    $self->{prvx} = $x;
    $self->{prvy} = $y;

    return ( $prvx, $prvy, $x, $y );
}

1;