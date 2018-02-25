=info
    Auth: 523066680/vicyang
    Date: 2018-02

    半径取值，rand(20.0) 改为 sqrt(rand(1.0)) * 20.0
    参考文章：
    http://blog.csdn.net/shakingwaves/article/details/17969025
    https://thecodeway.com/blog/?p=1138
=cut

use Modern::Perl;
use IO::Handle;
use List::Util qw/max min/;
use Time::HiRes qw/sleep time/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Points2D;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 600;
    our $WIDTH  = 800;
    our ($show_w, $show_h) = (100, 60);
    our ($half_w, $half_h) = ($show_w/2.0, $show_h/2.0);

    #创建随机颜色表
    our $total = 100;
    our @colormap;
    #srand(0.5);
    grep { push @colormap, [ 0.3+rand(0.7), 0.3+rand(0.7), 0.3+rand(0.7) ] } ( 0 .. $total*2 );

    our @dots;
    my ($inx, $iny);
    my ($len, $ang);
    my ($vx, $vy);   #速度分量
    $inx = 0.0;
    $iny = 0.0;

    for ( 0 .. $total )
    {
        ($len, $ang) = ( sqrt(rand(1.0)) * 20.0 , rand(6.28) );
        $vx = $len * sin( $ang );
        $vy = $len * cos( $ang );

        push @dots, 
                Points->new( 
                    x => $inx, y => $iny,
                    xs => $vx, ys => $vy,
                    rgb => $colormap[$_],
                    timeply => 2.0,
                );
    }
}

&main();

sub display
{
    our (@dots);
	my $t;
	state $iter = 1;
    state $size = 10.0;
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    my ( $ax, $ay, $bx, $by, $dot);

    $iter ++;

    for my $dot ( @dots )
    {
        glBegin(GL_LINES);
            ( $ax, $ay, $bx, $by ) = $dot->curr_pos();
            glColor3f( @{ $dot->{rgb} } );
            glVertex3f( $ax, $ay, 0.0);
            glVertex3f( $bx, $by, 0.0);
            #glVertex3f( $dot->{x}, $dot->{y}, 0.0);
        glEnd();
    }

    glAccum(GL_ACCUM, 1.0);
    glAccum(GL_MULT, 0.92);
    glAccum(GL_RETURN, 1.0);

    glutSwapBuffers();
}

sub idle 
{
    our (@dots, @colormap);
    our ($show_w, $show_h, $half_w, $half_h, $total );
    state $times = 0;
    state $size = 10.0;
    sleep 0.02;
    glutPostRedisplay();

    $times++;
    $size *= 0.9 if $size > 1.0;
    #$size *= 1.01;
    glLineWidth( $size );

    if ( $times % 50 == 0 )
    {
        $size = 10.0;
        @dots = ();
        my ($inx, $iny);
        my ($len, $ang);
        my ($vx, $vy);   #速度分量

        $inx = rand($show_w) - $half_w;
        $iny = rand($show_h) - $half_h;
        for ( 0 .. $total )
        {
            ($len, $ang) = ( sqrt(rand(1.0)) * 20.0, rand(6.28) );
            $vx = $len * sin( $ang );
            $vy = $len * cos( $ang );

            push @dots, 
                    Points->new( 
                        x => $inx, y => $iny,
                        xs => $vx, ys => $vy,
                        right => $show_w, 
                        rgb => $colormap[$_],
                        timeply => 1.0,
                    );
        }
    }

    # if ( $#dots < 200 )
    # {
    #     my ($inx, $iny);
    #     my ($len, $ang);
    #     push @dots, Points->new( x => 0.0, y => 0.0 , right => $show_w, rgb => $colormap[ $#dots ] );
    # }
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClearAccum(0.0, 0.0, 0.0, 0.0);
    glEnable(GL_DEPTH_TEST);
    glPointSize(4.0);
}

sub reshape
{
    our ($show_w, $show_h, $half_w, $half_h );
    state $fa = 100.0;
    my ($w, $h) = (shift, shift);
    my ($max, $min) = (max($w, $h), min($w, $h) );

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrtho(-$half_w, $half_w, -$half_h, $half_h, 0.0, $fa*2.0); 
    #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0, $fa);
}

sub hitkey
{
    our $WinID;
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }
}

sub quit
{
    our ($WinID);
    glutDestroyWindow( $WinID );
    exit 0;
}

sub main
{
    our ($WIDTH, $HEIGHT, $WinID);

    glutInit();
    glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH | GLUT_MULTISAMPLE );
    glutInitWindowSize($WIDTH, $HEIGHT);
    glutInitWindowPosition(100, 100);
    $WinID = glutCreateWindow("Free-fall");
    
    &init();
    glutDisplayFunc(\&display);
    glutReshapeFunc(\&reshape);
    glutKeyboardFunc(\&hitkey);
    glutIdleFunc(\&idle);
    glutMainLoop();
}