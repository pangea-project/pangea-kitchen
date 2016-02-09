#!/usr/bin/python

import unittest
import tempfile
import os
import prune
import shutil
import subprocess

class TestStringMethods(unittest.TestCase):

    imageTypes = ["unstable-proposed", "unstable", "user"]
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
