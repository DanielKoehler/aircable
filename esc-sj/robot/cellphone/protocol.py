# -*- coding: utf-8 -*-
import time, re

try:
    import select
except:
    pass
    
S60=False

try:
    import e32
    S60=True
except:
    pass

COMMAND_LINE="$GENIESYS%04X\r\n"
CAPTURE_SIZE=re.compile("\$SZE\s*(?P<size>\d+)")

COMMANDS=[
    'COMMAND_ECHO',
    'SET_COMMAND_MODE',
    'SET_PREVIEW_MODE',
    'CAPTURE_COMMAND',
    'SET_CAPTURE_VGA',
    'SET_CAPTURE_QVGA',
    'SET_CAPTURE_QQVGA',
    'GET_VERSION',
    'GET_CAPTURE_SIZE',
    'START_CAPTURE_SEND',
    'SET_RAW_REGISTER',
    'GET_RAW_REGISTER',
    'SET_CAPTURE_SVGA',
    'SET_CAPTURE_XVGA',
    'READ_EEPROM',
    'WRITE_EEPROM',
    'RESET_COMMAND'
]

SIZES = {
    'VGA': 'SET_CAPTURE_VGA',
    'QVGA': 'SET_CAPTURE_QVGA',
    'QQVGA': 'SET_CAPTURE_QQVGA',
    'SVGA': 'SET_CAPTURE_SVGA',
    'XVGA': 'SET_CAPTURE_XVGA',
}

def btselect(in_objs, out_objs, exp_objs, timeout=None):
    ready_in = []
    
    for sock in in_objs:
	if sock._recv_will_return_data_immediately():
	    ready_in.append(sock)

    import e32socket, e32
    lock = e32.Ao_lock()
    if timeout is not None and timeout > 0:
	e32.ao_sleep(timeout, lock.signal)

    if len(ready_in) > 0 or timeout == 0:
	return ( ready_in, [], [] )

    def callback(sock):
	ready_in.append(sock)
	lock.signal()


    for sock in in_objs:
	sock._set_recv_listener(lambda sock=sock:callback(sock))
    lock.wait()
    for sock in in_objs:
	sock._set_recv_listener(None)
    return (ready_in, [], [])

def isPyS60(sock):
    return getattr(sock, 'read_all', None)

def btsendall(socket, data):
    print "btsend", data
    socket.send(data)
    return

def btrecv(socket, bufsize):
    data=socket.recv(bufsize)
    
    return data

def do_sendall(sock, data):
    if isPyS60(sock):
	return btsendall(sock, data)
    return sock.sendall(data, socket.MSG_WAITALL)
    
def do_read(sock, bufsize):
    data = sock.recv(bufsize)
    print "do_read", bufsize, len(data)
    return data

def do_select(sock, timeout=1):
    if isPyS60(sock):
        rl = btselect([sock, ], [], [], timeout)
    else:
	rl = select.select([sock, ], [], [], timeout)
    return rl

def send_command(socket, command):
    print "send_command", command
    if type(command) == str:
        command = COMMANDS.index(command)
    command = COMMAND_LINE % command
    return do_sendall(socket, command)

def readbuffer(socket, timeout=0.2, ending=None, bufsize=0xffff, sleep=0.1):
    print "readbuffer", timeout, ending, bufsize, sleep
    o = ''
    a = 0
    last = time.time()
    while [ 1 ]:
	rl = do_select(socket, sleep)[0] # wait until we're ready or timeout
	if len(rl) > 0:
	    b=do_read(socket, bufsize)
    	    a=len(b)
    	    if a>0:
    		o+=b
    		last=time.time()
	if len(o) > 0:
	    if ending:
	        if o.find(ending)>0:
	    	    print "found ending"
		    break
	    elif a==0:
		print "no more data"
    		break
	if timeout and time.time()-last > timeout:
	    print "reached timeout"
	    break
	a = 0
    return o

def clearbuffer(socket, timeout=1, sleep=0.2):
    print "clear buffer"
    print readbuffer(socket, timeout=timeout, sleep=sleep)

def readline(socket, timeout=0.5, sleep=0.2):
    print "readline"
    out = readbuffer(socket, timeout, '\r\n', bufsize=1, sleep=sleep)
    return out

def command_echo(socket):
    send_command(socket, 'COMMAND_ECHO')
    l = readbuffer(socket, timeout=0.5, sleep=0.5)
    if l.find('ACK') > 0:
        print "got reply", l
    else:
	print l
    return

def set_command_mode(socket, timeout=1.5):
    send_command(socket, 'SET_COMMAND_MODE')

def set_capture_mode(socket, size='VGA', timeout=0.5):
    print "set capture mode", size
    send_command(socket, SIZES[size])

def capture_command(socket, timeout=0.5):
    send_command(socket, 'CAPTURE_COMMAND')

def get_capture_size(socket, timeout=1):
    while [ 1 ]:
	send_command(socket, 'GET_CAPTURE_SIZE')
	for line in readbuffer(socket, timeout).splitlines():
	    res = CAPTURE_SIZE.match(line.strip())
	    if res:
		return int(res.groupdict()['size'])

def start_capture_send(socket, size, timeout=0.2):
    send_command(socket, 'START_CAPTURE_SEND')
    ini = time.time()
    out = ""
    prev = len(out)
    while [ 1 ]:
	out += readbuffer(socket, timeout, sleep=0.2, bufsize=200)
	if prev == len(out): # got nothing for 2 cycles
	    return out
	prev += len(out)

def setup(socket, timeout=0.2, size='VGA'):
    print "setup"
    command_echo(socket)
    clearbuffer(socket, timeout=1.5, sleep=0.1) # wait for processor to be ready
    set_command_mode(socket)
    clearbuffer(socket, timeout=1.5, sleep=0.1) # wait for processor to be ready
    set_capture_mode(socket, size=size, timeout=timeout)
    clearbuffer(socket, timeout=1.5, sleep=0.1)

def grab_picture(socket, timeout=0.2):
    print "grab_picture"
    send_command(sock, 'RESET_COMMAND')
    capture_command(socket, timeout=timeout)
    clearbuffer(socket, timeout=timeout)
    size = get_capture_size(socket, timeout=timeout)
    if size == 0xFFFFFFFF:
        raise Exception("function not supported")
    return start_capture_send(socket, size, timeout)

JPG_START=chr(0xff)+chr(0xD8)
JPG_END  =chr(0xff)+chr(0xD9)
def find_jpeg(buffer):
    print "find_jpeg"
    start = None
    end = None
    if buffer.rfind(JPG_END)>-1:
	end = buffer.rfind(JPG_END)
	if buffer.rfind(JPG_START, 0, end)>-1:
	    start = buffer.rfind(JPG_START, 0, end)
    return start, end

def stream_mode(sock, timeout=0.2, drop=False):
    print "stream mode"
    send_command(sock, 'SET_PREVIEW_MODE')

    buf=""
    while [ 1 ]:
	# don't block until data is ready
	rl = do_select(sock, timeout=None)[0]
	if len(rl)==0:
	    continue
	print "reading buffer"
	buf+=do_read(sock, 4096*2)
	print "readed so far", len(buf)
	start, end = find_jpeg(buf)
	print "start, end", start, end
	if start is not None and end is not None and (start!=end and start<end):
	    print "found picture"
	    yield buf[start:end+2]
	    if drop:
		# drop the rest
		print "dropping", len(buf)
		buf=''
	    else:
		buf=buf[end+2:]
		print "remaining buffer", len(buf)

def test(address="00:22:BF:00:01:34", pyS60=True):
    if pyS60:
	import btsocket as socket
    else:
	import socket
    
    addr=(address, 1)
    sock=socket.socket(socket.AF_BT,socket.SOCK_STREAM)
    sock.connect(addr)
    setup(sock, size='QVGA')
    if not pyS60:
	return sock

    def redraw(rect):
	canvas.blit(img) 

    import airbotgraphics as graphics
    import appuifw, e32
    TEMP_FILE='E:\\camera_temp.jpg'
    
    canvas = None
    g=stream_mode(sock)#, drop=True)
    
    appuifw.app.screen = 'full'
    appuifw.app.orientation = 'landscape'

    img = graphics.Image.new((480, 360))
    canvas = appuifw.Canvas(redraw_callback=redraw)
    appuifw.app.body=canvas
    
    canvas.blit(img)
    for i in range(50):
	#e32.ao_yield()
	print time.time(), "grabbing picture"
	d=g.next()

	print time.time(),"loading picture"
	try:
	    img=graphics.Image.from_buffer(d)#, targetX=480, targetY=360)
	    e32.ao_yield()

	    print time.time(),"doing canvas blit"
	    canvas.blit(img)
	except Exception, err:
	    print time.time(),"error", err
    sock.close()

if __name__=='__main__':
    if pyS60:
      test()
    import sys

    pybluez = False

    try:
	from socket import MSG_WAITALL
	import bluetooth as socket
	socket.MSG_WAITALL = MSG_WAITALL
	pybluez = True
	print "pybluez available"
    except:
	import socket
    
    if len(sys.argv) < 3:
        print "usage %s target [--stream] <output or count>" % sys.argv[0]
        sys.exit(1)
    
    target = sys.argv[1]
    if pybluez:
	sock = socket.BluetoothSocket( proto = socket.RFCOMM );
    else:
	sock = socket.socket( 
            socket.AF_BLUETOOTH,
	    socket.SOCK_STREAM,
	    socket.BTPROTO_RFCOMM
	);

    #Let BlueZ decide outgoing port
    print 'binding to %s, %i' % ( 0, 0 )
    #sock.bind( (,0) );

    print 'connecting to %s, %i' % ( target, 1 )
    sock.connect( (target, 1) );
    clearbuffer(sock, 2)
    
    setup(sock, size="VGA")
    
    print "setup done"

    nam = "output"
    ext = "jpg"

    import os, sys
    j = 0
    
    send_command(sock, 'SET_PREVIEW_MODE')

    stream=stream_mode(sock)
    while [ 1 ]:
	pic=stream.next()
	b=file("%s_%i.%s" % (nam,j,ext), "wb")
	b.write(pic)
	b.close()
	os.system('xv %s.%s' %(nam, ext))
	Image.open(nam+"."+ext).show()
	j+=1
