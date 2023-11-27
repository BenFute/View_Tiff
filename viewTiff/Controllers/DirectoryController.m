//
//  DirectoryController.m
//  viewTiff
//
//  Created by Ben Larrison on 11/2/22.
//

#import "DirectoryController.h"

@implementation DirectoryController

+   (NSURL *)localDocumentsDirectoryURL
{
    NSString    *localDocumentsDirectoryPath            =       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSURL       *localDocumentsDirectoryURL             =       [NSURL      fileURLWithPath:localDocumentsDirectoryPath];
    
    return      localDocumentsDirectoryURL;
}

+   (NSURL *) photosDirectoryURL
{
    
    
    NSString        *photosDirName                      =       @"Photos";
    NSURL           *photosDirURL                       =       [self               localDocumentsDirectoryURL];
    photosDirURL                                        =       [photosDirURL       URLByAppendingPathComponent:photosDirName];
    
    //Check if photos dir already exists, create if necessary
    NSFileManager   *fm                                 =       [NSFileManager      defaultManager];
    NSArray         <NSString *> *mainDirContents       =       [fm                 contentsOfDirectoryAtPath:(NSString *)[self localDocumentsDirectoryURL] error:NULL];
    
    int             photosDirFound                      =       0;
    for(int i = 0; i < mainDirContents.count; i++)
    {
        if([photosDirName   isEqual:[mainDirContents objectAtIndex:i]])
        {
            photosDirFound          =       1;
        }
    }
    
    
    if(photosDirFound == 1)
    {
        return photosDirURL;
    }
    else
    {
        //Create the Dir
        BOOL        dirCreated                          =       [fm                 createDirectoryAtURL:photosDirURL withIntermediateDirectories:YES attributes:nil error:NULL];
        
        if(dirCreated)      return photosDirURL;
        else {
            NSLog(@"Usage: Find local documentsURL, create photos directory URL, search for photos directory, create if not found.");
            return      [self   localDocumentsDirectoryURL];

        }
    }
}

+   (NSURL  *) videoDirectoryURL
{
    NSString        *videoDirName                       =       @"Video";
    NSURL           *videoDirURL                        =       [self               localDocumentsDirectoryURL];
    videoDirURL                                         =       [videoDirURL       URLByAppendingPathComponent:videoDirName];
    
    
    //Check if video dir already exists, create if necessary
    NSFileManager   *fm                                 =       [NSFileManager      defaultManager];
    NSArray         <NSString *> *mainDirContents       =       [fm                 contentsOfDirectoryAtPath:(NSString *)[self localDocumentsDirectoryURL] error:NULL];
    int             videoDirFound                       =       0;
    
    for(int i = 0; i < mainDirContents.count; i++)
    {
        if([videoDirName    isEqual:[mainDirContents    objectAtIndex:i]])
        {
            videoDirFound           =       1;
        }
    }
    
    if(videoDirFound                ==       1)
    {
        return videoDirURL;
    }
    else
    {
        //create the Dir
        BOOL        dirCreated      =       [fm         createDirectoryAtURL:videoDirURL withIntermediateDirectories:YES attributes:nil error:NULL];
        
        if(dirCreated)                      return videoDirURL;
        else {
            NSLog(@"Usage: Find local documents Directory, create video directory URL, search for video directory, create if not found.");
            return                          [self       localDocumentsDirectoryURL];
        }
    }
    
}


+   (NSString *)createNextPhotoName
{
    NSURL           *searchDir                          =       [DirectoryController            photosDirectoryURL];
    
    NSString        *nextPhotoName                      =       @"Photo0";
    int             numPhotos                           =       1;
    
    NSFileManager   *fm                                 =       [NSFileManager                  defaultManager];
    NSArray         <NSString*> *dirContents            =       [fm                             contentsOfDirectoryAtPath:(NSString *)searchDir error:NULL];
    
    for(int i = 0; i < dirContents.count; i++)
    {
        if([[nextPhotoName      stringByAppendingString:@".tiff"]           isEqual:[dirContents objectAtIndex:i]])
        {
            nextPhotoName                               =       @"Photo";
            nextPhotoName                               =       [nextPhotoName                  stringByAppendingString:[NSString       stringWithFormat:@"%d",numPhotos]];
            numPhotos++;
            i                                           =       -1;
        }
    }
    
    return          nextPhotoName;
}

+   (void)  previewPhotoArrayWithVideoDirNums:(int**)videoNums photoNum:(int**)photoNums
{
    int*            photoArray                  =   *photoNums;
    int*            videoArray                  =   *videoNums;
    
    
    NSFileManager   *fm                         =   [NSFileManager          defaultManager];
    NSArray         <NSString*> *dirContents    =   [fm                     contentsOfDirectoryAtPath:(NSString *)[DirectoryController videoDirectoryURL] error:NULL];

    for(int i = 0; i < dirContents.count; i++)
    {
        
        NSString*   videoDirName    =   [dirContents            objectAtIndex:i];
        //remove extension
        NSCharacterSet  *decimalSet =   [NSCharacterSet         decimalDigitCharacterSet];
        decimalSet                  =   [decimalSet             invertedSet];
        
        int dirNum                  =   [videoDirName           stringByTrimmingCharactersInSet:decimalSet].intValue;
        
        videoArray[i]               =   dirNum;
        photoArray[i]               =   [DirectoryController    getPreviewPhotoNumber:dirNum];
    }
    
    
}

+   (NSURL *)getPreviewPhoto:(int)videoDir
{
    NSURL           *searchDir                          =       [DirectoryController        videoDir:videoDir];
    
    NSString        *photoName                          =       @"Photo0";
    int             numPhotos                           =       0;
    
    NSFileManager   *fm                                 =       [NSFileManager              defaultManager];
    NSArray         <NSString*> *dirContents            =       [fm                         contentsOfDirectoryAtPath:(NSString*)searchDir error:NULL];
    
    NSLog(@"Dir contents: %@",dirContents);
    
    for(int i = 0; i < (int)[DirectoryController getNumPhotos] + 1; i++)
    {
        photoName                                   =       @"Photo";
        photoName                                   =       [photoName                  stringByAppendingString:[NSString       stringWithFormat:@"%d.tiff",i]];
        
        
        for(int j = 0; j < (int)dirContents.count; j++)
        {
            NSLog(@"%@ == %@",photoName,[dirContents objectAtIndex:j]);

            if([photoName   isEqual:[dirContents        objectAtIndex:j]])
            {
                //Break out of the search
                NSLog(@"Found photo %@",photoName);
                i = (int)[DirectoryController getNumPhotos] + 1;
                j = (int)dirContents.count;
            }
        }

    }
    
    return      [searchDir      URLByAppendingPathComponent:photoName];
    
}

+   (int)getPreviewPhotoNumber:(int)videoDir
{
    NSURL           *searchDir                          =       [DirectoryController        videoDir:videoDir];
    
    NSString        *photoName                          =       @"Photo0";
    int             photoNum                            =       0;
    
    NSFileManager   *fm                                 =       [NSFileManager              defaultManager];
    NSArray         <NSString*> *dirContents            =       [fm                         contentsOfDirectoryAtPath:(NSString*)searchDir error:NULL];
    
    for(int i = 0; i < (int)[DirectoryController getNumPhotos] + 1; i++)
    {
        photoName                                       =       @"Photo";
        photoName                                       =       [photoName                  stringByAppendingString:[NSString   stringWithFormat:@"%d.tiff",i]];
        
        
        for(int j = 0; j < (int)dirContents.count; j++)
        {
            if([photoName       isEqual:[dirContents        objectAtIndex:j]])
            {
                photoNum        =       i;
                //Break out of the search
                i   =   (int)[DirectoryController   getNumPhotos] + 1;
                j   =   (int)dirContents.count;
            }
        }
    }
    
    return      photoNum;
}

+ (int)createNextVideoDir
{
    NSURL           *searchDir                          =       [DirectoryController                videoDirectoryURL];
    
    NSString        *nextVideoDirName                   =       @"Video0";
    int             numVideos                           =       0;
    
    NSFileManager   *fm                                 =       [NSFileManager                      defaultManager];
    NSArray         <NSString *>*dirContents            =       [fm                                 contentsOfDirectoryAtPath:(NSString *)searchDir error:NULL];
    
    for(int i = 0; i < dirContents.count; i++)
    {
        if([[nextVideoDirName stringByAppendingString:@".vtif"] isEqual:[dirContents objectAtIndex:i]])
        {
            numVideos++;
            nextVideoDirName                            =       @"Video";
            nextVideoDirName                            =       [nextVideoDirName                   stringByAppendingString:[NSString       stringWithFormat:@"%d",numVideos]];
            i                                           =       -1;
        }
    }
    
    [self createVideoDir:numVideos];
    
    return numVideos;
}

+   (NSString*)createNextVideoName:(int)videoDir
{
    NSURL           *searchDir                          =       [DirectoryController                videoDir:videoDir];
    
    NSString        *nextVideoName                      =       @"Video0";
    int             numVideos                           =       0;
    
    NSFileManager   *fm                                 =       [NSFileManager                      defaultManager];
    NSArray         <NSString *>*dirContents            =       [fm                                 contentsOfDirectoryAtPath:(NSString *)searchDir error:NULL];
    
    for(int i = 0; i < dirContents.count; i++)
    {
        if([nextVideoName isEqual:[dirContents objectAtIndex:i]])
        {
            numVideos++;
            nextVideoName                               =       @"Video";
            nextVideoName                               =       [nextVideoName                      stringByAppendingString:[NSString       stringWithFormat:@"%d",numVideos]];
            i                                           =       -1;
        }
    }
    
    return nextVideoName;
    
}

+   (int)nextVideoNum:(int)videoDir
{
    NSURL           *searchDir                          =       [DirectoryController            videoDir:videoDir];
    
    NSString        *nextVideoName                      =       @"Video0";
    int             numVideos                           =       0;
    
    NSFileManager   *fm                                 =       [NSFileManager                  defaultManager];
    NSArray         <NSString *>*dirContents            =       [fm                             contentsOfDirectoryAtPath:(NSString *)searchDir error:NULL];
    
    for(int i = 0; i < dirContents.count; i++)
    {
        if([nextVideoName isEqual:[dirContents objectAtIndex:i]])
        {
            numVideos++;
            nextVideoName                               =       @"Video";
            nextVideoName                               =       [nextVideoName      stringByAppendingString:[NSString       stringWithFormat:@"%d",numVideos]];
            i                                           =       -1;
        }
    }
    return numVideos;
}

+   (NSURL      *)videoURL:(int)dirNum videoNum:(int)videoNum
{
    NSURL           *videoURL                           =       [DirectoryController                videoDir:dirNum];
    
    videoURL                                            =       [videoURL       URLByAppendingPathComponent:[DirectoryController createVideoName:videoNum]];
    
    return          videoURL;;
    
}

+   (NSString   *)createVideoName:(int)videoNum
{
    NSString        *videoName                          =       @"Video";
    videoName                                           =       [videoName  stringByAppendingString:[NSString  stringWithFormat:@"%d",videoNum]];
    
    return          videoName;;
}

+   (NSString   *)getItemName:(NSURL *)itemURL
{
    NSString    *itemName;
    
    itemName                                            =       [itemURL.lastPathComponent          substringWithRange:NSMakeRange(0, itemURL.lastPathComponent.length - 5)];
    
    return      itemName;
}


+   (int)getPhotoNumber:(NSURL *)itemURL
{
    NSString    *photoName                              =       [DirectoryController                getItemName:itemURL];
    
    NSString    *numberString                           =       [photoName                          substringWithRange:NSMakeRange(5, photoName.length - 5)];
    
    return numberString.intValue;
    
}

+   (NSURL *)   videoDir:(int)dirNum
{
    NSString            *dirName                        =       @"Video";
    NSURL               *dirsURL                        =       [self                               videoDirectoryURL];
    dirName                                             =       [dirName                            stringByAppendingString:[NSString   stringWithFormat:@"%d.vtif",dirNum]];
    dirsURL                                             =       [dirsURL                            URLByAppendingPathComponent:dirName];
    
    NSArray<NSString *> *documentContents               =       [[NSFileManager                     defaultManager]     contentsOfDirectoryAtPath:(NSString *)[self videoDirectoryURL] error:NULL];
    
    BOOL                dirExists                       =       NULL;
    
    for(int i = 0; i < documentContents.count; i++)
    {
        if([dirName     isEqual:[documentContents   objectAtIndex:i]]){
            dirExists                                   =       TRUE;
        }
        
    }
    
    
    if(dirExists)
    {
        return dirsURL;
    }
    else
    {
        NSLog(@"Usage: create Video%d, search for it, return its URL if it exists");
        return [self        localDocumentsDirectoryURL];
    }
}

+   (int)getVideoDirectoryCount
{
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    NSArray <NSString*> *dirContents                    =       [fm                                 contentsOfDirectoryAtPath:(NSString *)[DirectoryController videoDirectoryURL] error:NULL];
    
    return              (int)dirContents.count;
}

+   (int)getNumVideosInVideoDirectory:(int)videoDir
{
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    NSArray <NSString*> *dirContents                    =       [fm             contentsOfDirectoryAtPath:(NSString *)[DirectoryController videoDir:videoDir] error:NULL];
    return              (int)dirContents.count;
}

+   (int)getNumPhotos
{
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    NSArray <NSString*> *dirContents                    =       [fm                                 contentsOfDirectoryAtPath:(NSString *)[DirectoryController photosDirectoryURL] error:NULL];
    
    return              (int)dirContents.count;
}


+   (void)  createDir:(int)dirNum inDir:(NSURL *)dir;
{
    NSURL               *dirsURL                        =       dir;
    NSString            *dirName                        =       @"Dir";
    dirName                                             =       [dirName                            stringByAppendingString:[NSString   stringWithFormat:@"%d",dirNum]];
    dirsURL                                             =       [dirsURL                            URLByAppendingPathComponent:dirName];
    
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    NSArray <NSString*> *documentsDirContents           =       [fm                                 contentsOfDirectoryAtPath:(NSString *)dir error:NULL];
    
    BOOL                dirExists   =   NULL;
    BOOL                dirCreated  =   NULL;
    
    for(int i = 0;  i < documentsDirContents.count; i++)
    {
        if([dirName         isEqual:[documentsDirContents       objectAtIndex:i]])
        {
            dirExists                                   =       TRUE;
        }
    }
    
    if(dirExists) NSLog(@"Dir%d already exists.",dirNum);
    else
    {
        dirCreated                                      =       [fm                                 createDirectoryAtURL:dirsURL withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if(dirCreated);
    else NSLog(@"Usage: Create Dir URL, create directory with NSFileManager");
}

+   (void)  deleteVideoDir:(int)dirNum
{
    NSURL               *dirsURL                        =       [self                               videoDirectoryURL];
    NSString            *dirName                        =       @"Video";

    dirName                                         =       [dirName                            stringByAppendingString:[NSString       stringWithFormat:@"%d.vtif",dirNum]];


    dirsURL                                             =       [dirsURL                            URLByAppendingPathComponent:dirName];
    
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    BOOL                directoryRemoved                =       [fm                                 removeItemAtURL:dirsURL error:nil];
    
    if(directoryRemoved);
    else                NSLog(@"Usage: Create dirsURL, remove url with NSFileManager");
}


+   (void)  createVideoDir:(int)videoNum
{
    NSURL               *dirsURL                        =       [self                               videoDirectoryURL];
    NSString            *dirName                        =       @"Video";
    dirName                                             =       [dirName                            stringByAppendingString:[NSString   stringWithFormat:@"%d.vtif",videoNum]];
    dirsURL                                             =       [dirsURL                            URLByAppendingPathComponent:dirName];
    
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    NSArray <NSString*> *videoDirContents               =       [fm                                 contentsOfDirectoryAtPath:(NSString*)[self    videoDirectoryURL] error:NULL];
    
    BOOL                dirExists                       =       NULL;
    BOOL                dirCreated                      =       NULL;
    
    for(int i = 0; i < videoDirContents.count; i++)
    {
        if([dirName     isEqual:[videoDirContents       objectAtIndex:i]])
        {
            dirExists                                   =       1;
        }
    }
    
    if(dirExists) NSLog(@"Video%d already exists.",videoNum);
    else
    {
        dirCreated                                      =       [fm                                 createDirectoryAtURL:dirsURL withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    if(dirCreated);
    else NSLog(@"Usage: Create Video URL, create directory with NSFileManager");
    
}

+   (NSURL *)createItemURLInDir:(NSURL *)Directory withName:(NSString *)itemName
{
    return      [Directory      URLByAppendingPathComponent:itemName];
}

+   (void)      listDirContents:(NSString *)dirName
{
    NSURL               *dirsURL                        =       [self                               localDocumentsDirectoryURL];
    dirsURL                                             =       [dirsURL                            URLByAppendingPathComponent:dirName];
    
    NSArray             *dirContents                    =       [[NSFileManager                     defaultManager] contentsOfDirectoryAtPath:(NSString*)dirsURL error:NULL];
    
    NSLog(@"%@ directory contents: \n%@",dirName,dirContents);
}

+   (void)      listVideoDirContents:(NSString *)dirName
{
    NSURL               *dirsURL                        =       [self                               videoDirectoryURL];
    dirsURL                                             =       [dirsURL                            URLByAppendingPathComponent:dirName];
    
    NSArray             *dirContents                    =       [[NSFileManager                     defaultManager]contentsOfDirectoryAtPath:(NSString*)dirsURL error:NULL];
    
    NSLog(@"%@ directory contents: \n%@",dirName,dirContents);
}

+   (int)       getNumItemsInDir:(NSURL *)dir
{
    NSFileManager       *fm                             =       [NSFileManager                      defaultManager];
    NSArray <NSString *>*dirContents                    =       [fm                                 contentsOfDirectoryAtPath:(NSString *)dir error:NULL];
    return              (int)dirContents.count;
}


@end
