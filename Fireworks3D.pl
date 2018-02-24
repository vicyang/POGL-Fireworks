use Modern::Perl;
use IO::Handle;
use List::Util qw/max min/;
use Time::HiRes qw/sleep time/;
use OpenGL qw/ :all /;
use OpenGL::Config;
use Points3D;

STDOUT->autoflush(1);

BEGIN
{
    our $WinID;
    our $HEIGHT = 600;
    our $WIDTH  = 800;
    our ($show_w, $show_h) = (100, 60);
    our ($half_w, $half_h) = ($show_w/2.0, $show_h/2.0);

    # 全局旋转角度
    our ( $rx, $ry, $rz ) = ( 0.0, 0.0, 0.0 );


    # 初速度
   	our $g = 9.8;
   	our $ta = time();

    #创建随机颜色表
    our $total = 100;
    our @colormap;
    srand(0.5);
    grep { push @colormap, [ 0.3+rand(0.7), 0.3+rand(0.7), 0.3+rand(0.7) ] } ( 0 .. $total );

    our @dots;
    my ($inx, $iny, $inz);
    my ($len, $ang);
    my ($vx, $vy, $vz);   #速度分量

    $inx = 0.0;
    $iny = 10.0;
    $inz = 0.0;

    for ( 0 .. $total )
    {
        ($len, $ang) = ( rand(20.0), rand(6.28) );
        $vx = $len * sin( $ang );
        $vy = $len * cos( $ang );
        $vz = rand( 20.0 );

        push @dots, 
                Points->new( 
                    x => $inx, y => $iny, z => $inz,
                    xs => $vx, ys => $vy, zs => $vz,
                    left => -25.0, right => 25.0, 
                    bottom => -25.0, top => 25.0,
                    front => 25.0, back => -25.0,
                    rgb => $colormap[ $_ % 100 ]
                );
    }

}

&main();

sub display
{
    our ( @dots );
    our ( $rx, $ry, $rz );
	my $t;
	state $iter = 0.0;
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    my ($x, $y, $z);

    glPushMatrix();
    glRotatef( $rx, 1.0, 0.0, 0.0 );
    glRotatef( $ry, 0.0, 1.0, 0.0 );
    glRotatef( $rz, 0.0, 0.0, 1.0 );

    glBegin(GL_POINTS);
    for my $dot ( @dots )
    {
        ($x, $y, $z ) = $dot->curr_pos();
        glColor3f( @{ $dot->{rgb} } );
        glVertex3f( $x, $y, $z);
        #glVertex3f( $dot->{x}, $dot->{y}, 0.0);
    }
    glEnd();

    glPopMatrix();

    glAccum(GL_ACCUM, 1.0);
    glAccum(GL_MULT, 0.9);
    glAccum(GL_RETURN, 1.0);

    glutSwapBuffers();
}

sub idle 
{
    our (@dots, @colormap, $total);
    state $iter = 0;
    sleep 0.02;
    glutPostRedisplay();

    $iter++;
    if ( $iter % 100 == 0 )
    {
        @dots = ();
        my ($inx, $iny, $inz);
        my ($len, $ang);
        my ($vx, $vy, $vz);   #速度分量

        $inx = 0.0;
        $iny = 10.0;
        $inz = 0.0;

        for ( 0 .. $total )
        {
            ($len, $ang) = ( 20.0, rand(6.28) );
            $vx = $len * sin( $ang );
            $vy = $len * cos( $ang );
            $vz = rand( 20.0 ) - 10.0;

            push @dots, 
                    Points->new( 
                        x => $inx, y => $iny, z => $inz,
                        xs => $vx, ys => $vy, zs => $vz,
                        left => -25.0, right => 25.0, 
                        bottom => -25.0, top => 25.0,
                        front => 25.0, back => -25.0,
                        rgb => $colormap[$_]
                    );
        }
    }
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glEnable(GL_DEPTH_TEST);
    glClearAccum(0.0, 0.0, 0.0, 0.0);
    glPointSize(2.0);
}

sub reshape
{
    our ($show_w, $show_h, $half_w, $half_h);
    state $fa = 200.0;
    my ($w, $h) = (shift, shift);
    my ($max, $min) = (max($w, $h), min($w, $h) );

    glViewport(0, 0, $w, $h);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    #glOrtho( -$half_w, $half_w, -$half_h, $half_h, 0.0, $fa*2.0); 
    #glFrustum(-100.0, $WIDTH-100.0, -100.0, $HEIGHT-100.0, 800.0, $fa*5.0); 
    gluPerspective( 30.0, 1.0, 10.0, $fa*2.0 );
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(0.0,0.0,$fa, 0.0,0.0,0.0, 0.0,1.0,$fa);
}

sub hitkey
{
    our ($WinID, $rx, $ry, $rz );
    my $k = lc(chr(shift));
    if ( $k eq 'q') { quit() }
    elsif ( $k eq 'w' ) { $rx += 1.0 }
    elsif ( $k eq 's' ) { $rx -= 1.0 }
    elsif ( $k eq 'a' ) { $ry -= 1.0 }
    elsif ( $k eq 'd' ) { $ry += 1.0 }

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