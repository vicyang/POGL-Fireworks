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
    glAccum(GL_MULT, 0.9);
    glAccum(GL_RETURN, 1.0);

    glutSwapBuffers();
}

sub idle 
{
    our (@dots, @colormap);
    our ($show_w, $show_h, $half_w, $half_h, $total );
    state $iter = 0;
    state $size = 10.0;
    sleep 0.02;
    glutPostRedisplay();

    $iter++;
    #$size *= 0.9 if $size > 1.0;
    #$size *= 1.01;
    #glLineWidth( $size );

    my ($inx, $iny, $vx, $vy);
    my ($len, $ang);

    $inx = 0.0;
    $iny = 0.0;

    if ( $iter < 500 and $iter % 3 == 0 )
    {
        ($len, $ang) = ( 10.0+rand(30.0), -$iter/200.0*6.28 + 1.57  );
        #($len, $ang) = ( 10.0+rand(30.0), 90.0/360.0*6.28 * 1.0/4.0 - rand(1.0)  );
        $vx = $len * sin( $ang );
        $vy = $len * cos( $ang );

        push @dots, 
                Points->new( 
                    x => $inx, y => $iny,
                    xs => $vx, ys => $vy,
                    right => $show_w, 
                    rgb => $colormap[ $#dots % 100 ],
                    timeply => 1.0,
                );
    }
}

sub init
{
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glClearAccum(0.0, 0.0, 0.0, 0.0);
    glEnable(GL_DEPTH_TEST);
    glPointSize(4.0);
    glLineWidth(1.0);
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