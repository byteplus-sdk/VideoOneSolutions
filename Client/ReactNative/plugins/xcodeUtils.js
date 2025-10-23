// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

const path = require('path');

/**
 * Utility functions for working with Xcode projects
 */

/**
 * Find a file reference by name in the Xcode project
 * @param {Object} xcodeProject - The Xcode project object
 * @param {string} fileName - The name of the file to find
 * @returns {Object} - Object containing the file references that match the name
 */
function findFileReferenceByName(xcodeProject, fileName) {
    const fileReferences = xcodeProject.hash.project.objects.PBXFileReference;
    return Object.fromEntries(
        Object.entries(fileReferences).filter(
            ([key, value]) =>
                value.name === `"${fileName}"` || value.path === `"${fileName}"`,
        ),
    );
}

/**
 * Find a group by name in the Xcode project
 * @param {Object} xcodeProject - The Xcode project object
 * @param {string} groupName - The name of the group to find
 * @returns {string|null} - The UUID of the group if found, null otherwise
 */
function findGroupByName(xcodeProject, groupName) {
    const groups = xcodeProject.hash.project.objects.PBXGroup;
    const foundGroup = Object.entries(groups).find(([_, group]) => {
        return (
            group.name === `"${groupName}"` ||
            group.path === `"${groupName}"` ||
            group.path === groupName ||
            (group.name && group.name.replace(/"/g, '') === groupName) ||
            (group.path && group.path.replace(/"/g, '') === groupName)
        );
    });
    return foundGroup ? foundGroup[0] : null;
}

/**
 * Add a file to the Xcode project in a specific group
 * @param {Object} xcodeProject - The Xcode project object
 * @param {string} filePath - The path of the file to add
 * @param {string} groupName - The name of the group to add the file to
 * @returns {Object|null} - The file reference if added successfully, null otherwise
 */
function addFileToGroup(xcodeProject, filePath, groupName) {
    const fileName = path.basename(filePath);
    const groupUUID = findGroupByName(xcodeProject, groupName);

    if (!groupUUID) return null;

    // Remove existing file reference if it exists
    const existingFile = findFileReferenceByName(xcodeProject, fileName);
    const existingFileUUID = Object.keys(existingFile)[0];
    if (existingFileUUID) {
        delete xcodeProject.hash.project.objects.PBXFileReference[existingFileUUID];

        // Also remove from build file section if it exists
        const buildFiles = xcodeProject.hash.project.objects.PBXBuildFile;
        Object.keys(buildFiles).forEach((buildFileUUID) => {
            if (buildFiles[buildFileUUID].fileRef === existingFileUUID) {
                delete buildFiles[buildFileUUID];
            }
        });
    }

    // Create a new file reference UUID
    const fileRefUUID = xcodeProject.generateUuid();
    const fileRef = {
        isa: 'PBXFileReference',
        lastKnownFileType: 'file',
        name: `"${fileName}"`,
        path: `"${groupName}/${fileName}"`,
        sourceTree: '"SOURCE_ROOT"',
    };

    // Add the file reference to the project
    xcodeProject.hash.project.objects.PBXFileReference[fileRefUUID] = fileRef;

    // Add to build phase
    const buildFileUUID = xcodeProject.generateUuid();
    const buildFile = {
        isa: 'PBXBuildFile',
        fileRef: fileRefUUID,
    };

    xcodeProject.hash.project.objects.PBXBuildFile[buildFileUUID] = buildFile;

    // Add to resources build phase
    const resourcesBuildPhase = Object.values(
        xcodeProject.hash.project.objects.PBXResourcesBuildPhase,
    )[0];
    resourcesBuildPhase.files.push({ value: buildFileUUID, comment: fileName });

    // Add to group
    const group = xcodeProject.hash.project.objects.PBXGroup[groupUUID];
    if (!group.children.some((child) => child.comment === fileName)) {
        group.children.push({ value: fileRefUUID, comment: fileName });
    }

    return { fileRef: fileRefUUID };
}

module.exports = {
    findFileReferenceByName,
    findGroupByName,
    addFileToGroup,
};
