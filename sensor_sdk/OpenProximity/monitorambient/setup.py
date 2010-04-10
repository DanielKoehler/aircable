from setuptools import setup
from monitorambient import __version__

setup(name="SensorSDK Ambient Sensor",
    version=__version__,
    packages=['monitorambient',],
    summary="SensorSDK Ambient Sensor",
    description="""SensorSDK plugin""",
    long_description="""A sample plugin for ambient monitoring""",
    author="Naranjo Manuel Francisco",
    author_email= "manuel@aircable.net",
    license="GPL2",
    url="http://code.google.com/p/aircable/", 
)
