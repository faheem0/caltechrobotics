/*
 *  V4L2 video capture example
 *
 *  This program can be used and distributed without restrictions.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

#include <getopt.h>             /* getopt_long() */

#include <fcntl.h>              /* low-level i/o */
#include <unistd.h>
#include <errno.h>
#include <malloc.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/mman.h>
#include <sys/ioctl.h>

#include <asm/types.h>          /* for videodev2.h */

#include <linux/videodev2.h>

#include "graph.h" 

#define CLEAR(x) memset (&(x), 0, sizeof (x))

typedef enum {
    IO_METHOD_READ,
    IO_METHOD_MMAP,
    IO_METHOD_USERPTR,
} io_method;

struct buffer {
    void *                  start;
    size_t                  length;
};

static char		*dev_name        = NULL;
static io_method	io		= IO_METHOD_MMAP;
static int              fd              = -1;
struct buffer		*buffers         = NULL;
static unsigned int     n_buffers       = 0;

unsigned char		*clip_buffer	= NULL;

static void errno_exit(const char *           s) {
    fprintf(stderr, "%s error %d, %s\n",
            s, errno, strerror(errno));
    
    exit(EXIT_FAILURE);
}

static int xioctl(int fd, int request, void *arg)
{
    int r;
    
    do r = ioctl(fd, request, arg);
    while (-1 == r && EINTR == errno);
    
    return r;
}

static void process_image (const void *p, const size_t length, int *image)
{
    int i,j;
    unsigned char *v_buffer;

    v_buffer = (unsigned char *)p;
    memcpy(clip_buffer, v_buffer, length);
    for(i = 0, j = 0; i < length; i += 2, j++){
	image[j] = (int)v_buffer[i];
    }
}

static int read_frame (int *image)
{
    struct v4l2_buffer buf;
    unsigned int i;
    
            CLEAR(buf);
            
            buf.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            buf.memory = V4L2_MEMORY_MMAP;
            
            if (-1 == xioctl(fd, VIDIOC_DQBUF, &buf)) {
                switch (errno) {
                    case EAGAIN:
                        return 0;
                        
                    case EIO:
                        /* Could ignore EIO, see spec. */
                        
                        /* fall through */
                        
                    default:
                        errno_exit("VIDIOC_DQBUF");
                }
            }
            
            assert(buf.index < n_buffers);
            
            process_image(buffers[buf.index].start, buffers[buf.index].length, image);
            
            if (-1 == xioctl(fd, VIDIOC_QBUF, &buf))
                errno_exit("VIDIOC_QBUF");

    return 1;
}


static void mainloop (int *image)
{
    unsigned int count;
    
    count = 1;
    
    while (count-- > 0) {
        for (;;) {
            fd_set fds;
            struct timeval tv;
            int r;
            
            FD_ZERO(&fds);
            FD_SET(fd, &fds);
            
            /* Timeout. */
            tv.tv_sec = 2;
            tv.tv_usec = 0;
            
            r = select(fd + 1, &fds, NULL, NULL, &tv);
            
            if (-1 == r) {
                if (EINTR == errno)
                    continue;
                
                errno_exit("select");
            }
            
            if (0 == r) {
                fprintf(stderr, "select timeout\n");
                exit(EXIT_FAILURE);
            }
            
            if (read_frame(image))
                break;
            
            /* EAGAIN - continue select loop. */
        }
    }
}

static void stop_capturing (void)
{
    enum v4l2_buf_type type;
    
            type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            
            if (-1 == xioctl(fd, VIDIOC_STREAMOFF, &type))
                errno_exit("VIDIOC_STREAMOFF");
}

static void start_capturing (void)
{
    unsigned int i;
    enum v4l2_buf_type type;
    
            for (i = 0; i < n_buffers; ++i) {
                struct v4l2_buffer buf;
                
                CLEAR(buf);
                
                buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE;
                buf.memory      = V4L2_MEMORY_MMAP;
                buf.index       = i;
                
                if (-1 == xioctl(fd, VIDIOC_QBUF, &buf))
                    errno_exit("VIDIOC_QBUF");
            }
            
            type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
            
            if (-1 == xioctl(fd, VIDIOC_STREAMON, &type))
                errno_exit("VIDIOC_STREAMON");
            
}

static void uninit_device (void)
{
    unsigned int i;
    
    for (i = 0; i < n_buffers; ++i)
        if (-1 == munmap(buffers[i].start, buffers[i].length))
            errno_exit("munmap");
    
    free(buffers);
}

static void init_mmap (void)
{
    struct v4l2_requestbuffers req;
    
    CLEAR(req);
    
    req.count               = 4;
    req.type                = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    req.memory              = V4L2_MEMORY_MMAP;
    
    if (-1 == xioctl(fd, VIDIOC_REQBUFS, &req)) {
        if (EINVAL == errno) {
            fprintf(stderr, "%s does not support "
                    "memory mapping\n", dev_name);
            exit(EXIT_FAILURE);
        } else {
            errno_exit("VIDIOC_REQBUFS");
        }
    }
    
    if (req.count < 2) {
        fprintf(stderr, "Insufficient buffer memory on %s\n",
                dev_name);
        exit(EXIT_FAILURE);
    }
    
    buffers = calloc(req.count, sizeof (*buffers));
    
    if (!buffers) {
        fprintf(stderr, "Out of memory\n");
        exit(EXIT_FAILURE);
    }
    
    for (n_buffers = 0; n_buffers < req.count; ++n_buffers) {
        struct v4l2_buffer buf;
        
        CLEAR(buf);
        
        buf.type        = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        buf.memory      = V4L2_MEMORY_MMAP;
        buf.index       = n_buffers;
        
        if (-1 == xioctl(fd, VIDIOC_QUERYBUF, &buf))
            errno_exit("VIDIOC_QUERYBUF");
        
        buffers[n_buffers].length = buf.length;
        buffers[n_buffers].start =
                mmap(NULL /* start anywhere */,
                buf.length,
                PROT_READ | PROT_WRITE /* required */,
                MAP_SHARED /* recommended */,
                fd, buf.m.offset);
        
        if (MAP_FAILED == buffers[n_buffers].start)
            errno_exit("mmap");
    }
}


static void init_device (int width, int height)
{
    struct v4l2_capability cap;
    struct v4l2_cropcap cropcap;
    struct v4l2_crop crop;
    struct v4l2_format fmt;
    unsigned int min;
    
    if (-1 == xioctl(fd, VIDIOC_QUERYCAP, &cap)) {
        if (EINVAL == errno) {
            fprintf(stderr, "%s is no V4L2 device\n",
                    dev_name);
            exit(EXIT_FAILURE);
        } else {
            errno_exit("VIDIOC_QUERYCAP");
        }
    }
    
    if (!(cap.capabilities & V4L2_CAP_VIDEO_CAPTURE)) {
        fprintf(stderr, "%s is no video capture device\n",
                dev_name);
        exit(EXIT_FAILURE);
    }
    
    if (!(cap.capabilities & V4L2_CAP_STREAMING)) {
        fprintf(stderr, "%s does not support streaming i/o\n",
                dev_name);
        exit(EXIT_FAILURE);
    }
    
    
    /* Select video input, video standard and tune here. */
    
    
    CLEAR(cropcap);
    
    cropcap.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    
    if (0 == xioctl(fd, VIDIOC_CROPCAP, &cropcap)) {
        crop.type = V4L2_BUF_TYPE_VIDEO_CAPTURE;
        crop.c = cropcap.defrect; /* reset to default */
        
        if (-1 == xioctl(fd, VIDIOC_S_CROP, &crop)) {
            switch (errno) {
                case EINVAL:
                    /* Cropping not supported. */
                    break;
                default:
                    /* Errors ignored. */
                    break;
            }
        }
    } else {
        /* Errors ignored. */
    }
    
    
    CLEAR(fmt);
    
    fmt.type                = V4L2_BUF_TYPE_VIDEO_CAPTURE;
    fmt.fmt.pix.width       = width;
    fmt.fmt.pix.height      = height;
    //fmt.fmt.pix.width       = 640;
    //fmt.fmt.pix.height      = 480;
    fmt.fmt.pix.pixelformat = V4L2_PIX_FMT_YUYV;
    fmt.fmt.pix.field       = V4L2_FIELD_INTERLACED;
    
    if (-1 == xioctl(fd, VIDIOC_S_FMT, &fmt))
        errno_exit("VIDIOC_S_FMT");
    
    /* Note VIDIOC_S_FMT may change width and height. */
    
    /* Buggy driver paranoia. */
    min = fmt.fmt.pix.width * 2;
    if (fmt.fmt.pix.bytesperline < min)
        fmt.fmt.pix.bytesperline = min;
    min = fmt.fmt.pix.bytesperline * fmt.fmt.pix.height;
    if (fmt.fmt.pix.sizeimage < min)
        fmt.fmt.pix.sizeimage = min;

    clip_buffer = (char *)malloc(2*width*height*sizeof(char));
    init_mmap();
}

static void close_device (void)
{
    if (-1 == close(fd))
        errno_exit("close");
    
    fd = -1;
}

static void open_device (char *dev)
{
    struct stat st;
    dev_name = dev;
    
    if (-1 == stat(dev_name, &st)) {
        fprintf(stderr, "Cannot identify '%s': %d, %s\n",
                dev_name, errno, strerror(errno));
        exit(EXIT_FAILURE);
    }
    
    if (!S_ISCHR(st.st_mode)) {
        fprintf(stderr, "%s is no device\n", dev_name);
        exit(EXIT_FAILURE);
    }
    
    fd = open(dev_name, O_RDWR /* required */ | O_NONBLOCK, 0);
    
    if (-1 == fd) {
        fprintf(stderr, "Cannot open '%s': %d, %s\n",
                dev_name, errno, strerror(errno));
        exit(EXIT_FAILURE);
    }
}
///////////////////////////////////////////////////////
//Non Static routines
///////////////////////////////////////////////////////
void start_camera(char *dev, int width, int height)
{
    open_device(dev);
    init_device(width, height);
    start_capturing();
}
void stop_camera(void)
{
    stop_capturing();
    uninit_device();
    close_device();
}
void capture_frame (int *image)
{
        for (;;) {
            fd_set fds;
            struct timeval tv;
            int r;
            
            FD_ZERO(&fds);
            FD_SET(fd, &fds);
            
            /* Timeout. */
            tv.tv_sec = 2;
            tv.tv_usec = 0;
            
            r = select(fd + 1, &fds, NULL, NULL, &tv);
            
            if (-1 == r) {
                if (EINTR == errno)
                    continue;
                
                errno_exit("select");
            }
            
            if (0 == r) {
                fprintf(stderr, "select timeout\n");
                exit(EXIT_FAILURE);
            }
            
            if (read_frame(image))
                break;
            
            /* EAGAIN - continue select loop. */
        }
}
void test_image(char *dev, int *image, int width, int height)
{
    open_device(dev);
    init_device(width, height);
    start_capturing();
    mainloop(image);
    stop_capturing();
    uninit_device();
    close_device();
}
