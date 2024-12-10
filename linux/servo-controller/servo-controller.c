#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/mod_devicetable.h>
#include <linux/io.h>
#include <linux/mutex.h>
#include <linux/miscdevice.h>
#include <linux/types.h>
#include <linux/fs.h>
#include <linux/kstrtox.h>

#define DUTY_CYCLE_OFFSET 0

/**
* struct servo_controller_dev - Private rgb patterns device struct.
* @base_addr: Pointer to the component's base address
* @red_value: Address of the duty cycle register
* @miscdev: miscdevice used to create a character device
* @lock: mutex used to prevent concurrent writes to memory
*
* An servo_controller_dev struct gets created for each rgb patterns component.
*/
struct servo_controller_dev {
    void __iomem *base_addr;
    void __iomem *duty_cycle;
    struct miscdevice miscdev;
    struct mutex lock;
};

/**
* duty_cycle_show() - Return the duty cycle value
* to user-space via sysfs.
* @dev: Device structure for the servo_controller component. This
* device struct is embedded in the servo_controller' device struct.
* @attr: Unused.
* @buf: Buffer that gets returned to user-space.
*
* Return: The number of bytes read.
*/
static ssize_t duty_cycle_show(struct device *dev,
    struct device_attribute *attr, char *buf)
{
    u8 duty_cycle;

    // Get the private servo_controller data out of the dev struct
    struct servo_controller_dev *priv = dev_get_drvdata(dev);

    duty_cycle = ioread32(priv->duty_cycle);

    return scnprintf(buf, PAGE_SIZE, "%u\n", duty_cycle);
}

/**
* duty_cycle_store() - Store the duty_cycle value.
* @dev: Device structure for the servo_controller component. This
* device struct is embedded in the servo_controller'
* platform device struct.
* @attr: Unused.
* @buf: Buffer that contains the red_value value being written.
* @size: The number of bytes being written.
*
* Return: The number of bytes stored.
*/
static ssize_t duty_cycle_store(struct device *dev,
    struct device_attribute *attr, const char *buf, size_t size)
{
    u8 duty_cycle;
    int ret;
    struct servo_controller_dev *priv = dev_get_drvdata(dev);

    // Parse the string we received as a u8
    // See https://elixir.bootlin.com/linux/latest/source/lib/kstrtox.c#L289
    ret = kstrtou8(buf, 0, &duty_cycle);
    if (ret < 0) {
        // kstrtou8 returned an error
        return ret;
    }

    iowrite32(duty_cycle, priv->duty_cycle);

    // Write was successful, so we return the number of bytes we wrote.
    return size;
}

// Define sysfs attributes
static DEVICE_ATTR_RW(duty_cycle);

// Create an attribute group so the device core can
// export the attributes for us.
static struct attribute *servo_controller_attrs[] = {
    &dev_attr_duty_cycle.attr,
    NULL,
};
ATTRIBUTE_GROUPS(servo_controller);

/**
* servo_controller_read() - Read method for the servo_controller char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value into.
* @count: The number of bytes being requested.
* @offset: The byte offset in the file being read from.
*
* Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
* value is returned.
*/
static ssize_t servo_controller_read(struct file *file, char __user *buf,
    size_t count, loff_t *offset)
{
    size_t ret;
    u32 val;

    /*
    * Get the device's private data from the file struct's private_data
    * field. The private_data field is equal to the miscdev field in the
    * servo_controller_dev struct. container_of returns the
    * servo_controller_dev struct that contains the miscdev in private_data.
    */
    struct servo_controller_dev *priv = container_of(file->private_data,
                                    struct servo_controller_dev, miscdev);

    // Check file offset to make sure we are reading from a valid location.
    if (*offset < 0) {
        // We can't read from a negative file position.
        return -EINVAL;
    }
    if (*offset >= 16) {
        // We can't read from a position past the end of our device.
        return 0;
    }
    if ((*offset % 0x4) != 0) {
        // Prevent unaligned access.
        pr_warn("servo_controller_read: unaligned access\n");
        return -EFAULT;
    }

    val = ioread32(priv->base_addr + *offset);

    // Copy the value to userspace.
    ret = copy_to_user(buf, &val, sizeof(val));
    if (ret == sizeof(val)) {
        pr_warn("servo_controller_read: nothing copied\n");
        return -EFAULT;
    }

    // Increment the file offset by the number of bytes we read. 
    *offset = *offset + sizeof(val);

    return sizeof(val);
}

/**
* servo_controller_write() - Write method for the servo_controller char device
* @file: Pointer to the char device file struct.
* @buf: User-space buffer to read the value from.
* @count: The number of bytes being written.
* @offset: The byte offset in the file being written to.
*
* Return: On success, the number of bytes written is returned and the
* offset @offset is advanced by this number. On error, a negative error
* value is returned.
*/
static ssize_t servo_controller_write(struct file *file, const char __user *buf,
    size_t count, loff_t *offset)
    {
    size_t ret;
    u32 val;

    struct servo_controller_dev *priv = container_of(file->private_data,
    struct servo_controller_dev, miscdev);

    if (*offset < 0) {
        return -EINVAL;
    }
    if (*offset >= 16) {  
        return 0;
    }
    if ((*offset % 0x4) != 0) {
        pr_warn("servo_controller_write: unaligned access\n");
        return -EFAULT;
    }

    mutex_lock(&priv->lock);

    // Get the value from userspace.
    ret = copy_from_user(&val, buf, sizeof(val));
    if (ret != sizeof(val)) {
        iowrite32(val, priv->base_addr + *offset);

        // Increment the file offset by the number of bytes we wrote.
        *offset = *offset + sizeof(val);

        // Return the number of bytes we wrote.
        ret = sizeof(val);
    }
    else {
        pr_warn("servo_controller_write: nothing copied from user space\n");
        ret = -EFAULT;
    }

    mutex_unlock(&priv->lock);
    return ret;
}

/**
* servo_controller_fops - File operations supported by the
*                       servo_controller driver
* @owner: The servo_controller driver owns the file operations; this
*           ensures that the driver can't be removed while the
*           character device is still in use.
* @read: The read function.
* @write: The write function.
* @llseek: We use the kernel's default_llseek() function; this allows
*           users to change what position they are writing/reading to/from.
*/
static const struct file_operations servo_controller_fops = {
    .owner = THIS_MODULE,
    .read = servo_controller_read,
    .write = servo_controller_write,
    .llseek = default_llseek,
};

/**
* servo_controller_probe() - Initialize device when a match is found
* @pdev: Platform device structure associated with our rgb patterns device;
* pdev is automatically created by the driver core based upon our
* rgb patterns device tree node.
*
* When a device that is compatible with this rgb patterns driver is found, the
* driver's probe function is called. This probe function gets called by the
* kernel when an servo_controller device is found in the device tree.
*/
static int servo_controller_probe(struct platform_device *pdev)
{
    struct servo_controller_dev *priv;
    size_t ret;

    /*
    * Allocate kernel memory for the rgb patterns device and set it to 0.
    * GFP_KERNEL specifies that we are allocating normal kernel RAM;
    * see the kmalloc documentation for more info. The allocated memory
    * is automatically freed when the device is removed.
    */
    priv = devm_kzalloc(&pdev->dev, sizeof(struct servo_controller_dev),
    GFP_KERNEL);
    if (!priv) {
        pr_err("Failed to allocate memory\n");
        return -ENOMEM;
    }

    /*
    * Request and remap the device's memory region. Requesting the region
    * make sure nobody else can use that memory. The memory is remapped
    * into the kernel's virtual address space because we don't have access
    * to physical memory locations.
    */
    priv->base_addr = devm_platform_ioremap_resource(pdev, 0);
    if (IS_ERR(priv->base_addr)) {
        pr_err("Failed to request/remap platform device resource\n");
        return PTR_ERR(priv->base_addr);
    }

    // Set the memory addresses for the register.
    priv->duty_cycle = priv->base_addr + DUTY_CYCLE_OFFSET;
    

    // Send a duty cycle of 1.5 ms to the servo
    iowrite32(127, priv->duty_cycle);

    // Initialize the misc device parameters
    priv->miscdev.minor = MISC_DYNAMIC_MINOR;
    priv->miscdev.name = "servo_controller";
    priv->miscdev.fops = &servo_controller_fops;
    priv->miscdev.parent = &pdev->dev;

    // Register the misc device; this creates a char dev at /dev/servo_controller
    ret = misc_register(&priv->miscdev);
    if (ret) {
        pr_err("Failed to register misc device");
        return ret;
    }

    /* Attach the rgb patterns's private data to the platform device's struct.
    * This is so we can access our state container in the other functions.
    */
    platform_set_drvdata(pdev, priv);

    pr_info("servo_controller_probe successful\n");
    return 0;
}

/**
* servo_controller_remove() - Remove an rgb patterns device.
* @pdev: Platform device structure associated with our rgb patterns device.
*
* This function is called when an rgb patterns devicee is removed or
* the driver is removed.
*/
static int servo_controller_remove(struct platform_device *pdev)
{
    // Get the rgb patterns's private data from the platform device.
    struct servo_controller_dev *priv = platform_get_drvdata(pdev);
    
    // Deregister the misc device and remove the /dev/servo_controller file.
    misc_deregister(&priv->miscdev);

    pr_info("servo_controller_remove successful\n");

    return 0;
}

/*
39 * Define the compatible property used for matching devices to this driver,
40 * then add our device id structure to the kernel's device table. For a device
41 * to be matched with this driver, its device tree node must use the same
42 * compatible string as defined here.
43 */
static const struct of_device_id servo_controller_of_match[] = {
    { .compatible = "Raber,servo_controller", },
    { }
};
MODULE_DEVICE_TABLE(of, servo_controller_of_match);


/*
* struct servo_controller_driver - Platform driver struct for the servo_controller driver
* @probe: Function that's called when a device is found
* @remove: Function that's called when a device is removed
* @driver.owner: Which module owns this driver
* @driver.name: Name of the servo_controller driver
* @driver.of_match_table: Device tree match table
*/
static struct platform_driver servo_controller_driver = {
    .probe = servo_controller_probe,
    .remove = servo_controller_remove,
    .driver = {
        .owner = THIS_MODULE,
        .name = "servo_controller",
        .of_match_table = servo_controller_of_match,
        .dev_groups = servo_controller_groups,
    },
};

/*
* We don't need to do anything special in module init/exit.
* This macro automatically handles module init/exit.
*/
module_platform_driver(servo_controller_driver);

MODULE_LICENSE("Dual MIT/GPL");
MODULE_AUTHOR("Dylan Raber");
MODULE_DESCRIPTION("servo_controller driver");