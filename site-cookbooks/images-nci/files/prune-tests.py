#!/usr/bin/python

# Copyright Jonathan Riddell 2016
# May be copied under the GNU GPL 2 or later
#
# tests for prune-images script

import unittest
import tempfile
import os
import prune
import shutil

class TestStringMethods(unittest.TestCase):

    imageTypes = ["unstable-proposed", "unstable", "user"]
    # 4 images from today and 2 from yesterday, so 6 should get saved and the rest removed
    images = ["20160111-1706", "20160112-1325", "20160124-0301", "20160131-0123", "20160131-0234", "20160201-0123", "20160201-0234", "20160201-0345", "20160201-0456"]

    def setUp(self):
        self.tempDir = tempfile.mkdtemp()
        os.chdir(self.tempDir)
        for imageType in self.imageTypes:
            os.mkdir(imageType)
            for image in self.images:
                os.mkdir(imageType + "/" + image)
            os.symlink(self.images[-1:][0], imageType + "/current")

    def tearDown(self):
        shutil.rmtree(self.tempDir)

    def test_init(self):
        self.pruner = prune.Pruner(self.tempDir)
        self.assertEqual(self.pruner.baseDirectory, self.tempDir)
        self.assertEqual(self.pruner.today[:3], "201") # needs fixed in 2020
        self.assertEqual(self.pruner.yesterday[:3], "201") # needs fixed in 2020

    def test_getImageDirectories(self):
        self.pruner = prune.Pruner(self.tempDir)
        self.pruner.getImageDirectories()
        self.assertEqual(sorted(self.pruner.imageDirectories), sorted(self.imageTypes))

    def test_removeDirectories(self):
        self.pruner = prune.Pruner(self.tempDir)
        self.pruner.today = "20160201"
        self.pruner.yesterday = "20160131"
        self.pruner.getImageDirectories()
        self.pruner.removeDirectories()
        self.assertEqual(sorted(self.pruner.removeImageDirs), sorted(["20160111-1706", "20160112-1325", "20160124-0301"]))
        for directory in self.pruner.imageDirectories:
            remainingImages = os.listdir(directory)
            self.assertEqual(sorted(remainingImages), sorted(["20160131-0123", "20160131-0234", "20160201-0123", "20160201-0234", "20160201-0345", "20160201-0456", "current"]))

if __name__ == '__main__':
    unittest.main()
