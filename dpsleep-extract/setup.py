from setuptools import setup, find_packages

setup(name="extract",
      description="Phoenix GENEActiv EXTRACT Package",
      author="Neuroinformatics Research Group",
      author_email="support@neuroinfo.org",
      packages=find_packages(),
      url="http://neuroinformatics.harvard.edu/",
      install_requires=["pandas", "pytz", "gzip"]
)
