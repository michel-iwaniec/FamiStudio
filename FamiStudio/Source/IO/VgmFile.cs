﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using System.Diagnostics;

namespace FamiStudio
{
    public class VgmFile
    {
        unsafe struct VgmHeader
        {

            public fixed byte Vgm[4];
            public int eofOffset;
            public int version;
            public int sn76489clock;
            public uint ym2413clock;
            public int gd3Offset;
            public int totalSamples;
            public int loopOffset;
            public int loopSamples;
            public int rate;
            public short sn76489Feedback;
            public byte sn76489RegWidth;
            public byte sn76489Flags;
            public int ym2612clock;
            public int ym2151clock;
            public int vgmDataOffset;
            public int segaPCMClock;
            public int segaPCMReg;
            public int RF5C68clock;
            public int YM2203clock;
            public int YM2608clock;
            public int YM2610clock;
            public int YM3812clock;
            public int YM3526clock;
            public int Y8950clock;
            public int YMF262clock;
            public int YMF278Bclock;
            public int YMF271clock;
            public int YMZ280Bclock;
            public int RF5C164clock;
            public int PWMclock;
            public int AY8910clock;
            public byte AY8910ChipType;
            public byte AY8910Flags;
            public byte YM2203_AY8910Flags;
            public byte YM2608_AY8910Flags;
            public byte volumeMod;
            public byte reserved1;
            public byte loopBase;
            public byte loopModifier;
            public int GameBoyDMGclock;
            public uint NESAPUclock;
            public int MultiPCMclock;
            public int uPD7759clock;
            public int OKIM6258clock;
            public byte OKIM6258Flags;
            public byte K054539Flags;
            public byte C140ChipType;
            public byte reserved2;
            public int OKIM6295clock;
            public int K051649clock;
            public int K054539clock;
            public int HuC6280clock;
            public int C140clock;
            public int K053260clock;
            public int Pokeyclock;
            public int QSoundclock;
            public int SCSPclock;
            public int ExtraHeaderOffset;
        };
        public unsafe static void Save(Song song, string filename, int filetype)
        {
            var project = song.Project;
            var regPlayer = new RegisterPlayer(song.Project.OutputsStereoAudio);
            var writes = regPlayer.GetRegisterValues(song, project.PalMode);
            var lastWrite = writes.Last();

            using (var file = new FileStream(filename, FileMode.Create))
            {
                var header = new VgmHeader();
                header.Vgm[0] = (byte)'V';
                header.Vgm[1] = (byte)'g';
                header.Vgm[2] = (byte)'m';
                header.Vgm[3] = (byte)' ';
                header.version = 0x00000170;
                if (project.UsesVrc7Expansion) { header.ym2413clock = 3579545 + 0x80000000; }
                    
                if (project.UsesEPSMExpansion) { header.YM2608clock = 8000000; }
                if (project.UsesFdsExpansion) { header.NESAPUclock = 1789772 + 0x80000000; }
                else { header.NESAPUclock = 1789772; }
                if (project.UsesS5BExpansion) {
                    header.AY8910clock = 1789772;
                    header.AY8910ChipType = 0x10;
                }
                header.vgmDataOffset = 0x8C+29;
                header.totalSamples = lastWrite.FrameNumber*735;
                header.rate = 60;
                header.ExtraHeaderOffset = 0x4;
                
                string gd3 = "Gd3 ";
                string songName = song.Name + "\0";
                string gameName = song.Project.Name + "\0";
                string systemName = "NES/Famicom FamiStudio Export\0";
                string author = song.Project.Author + "\0";
                int gd3Lenght = gd3.Length + (songName.Length * 2) + (gameName.Length * 2) + (systemName.Length * 2) + (author.Length * 2) + 2 + 2 + 2 + 2 + 2 + 4 + 4 + 4;

                var sampleData = project.GetPackedSampleData();



                if (filetype == 1)
                {
                    var fileLenght = sizeof(VgmHeader) + 39 - 4 +29 + 1; //headerbytes + init bytes (39)  - offset (4bytes)  + extraheader (29bytes) + audio stop 1byte
                    int frameNumber = 0;
                    foreach (var reg in writes)
                    {
                        while (frameNumber < reg.FrameNumber)
                        {
                            frameNumber++;
                            fileLenght++;
                        }
                        switch (reg.Register)
                        {
                            case 0x401d:
                            case 0x401f:
                            case 0x9030:
                            case 0xE000:
                            case int expression when (reg.Register < 0x401c) || (reg.Register < 0x409f && reg.Register > 0x401F):
                                fileLenght = fileLenght + 3;
                                break;
                        }
                    }
                    fileLenght = fileLenght + sampleData.Length + 9;
                    header.gd3Offset = fileLenght - 16;
                    fileLenght = fileLenght + gd3Lenght;
                    header.eofOffset = fileLenght; 
                    var headerBytes = new byte[sizeof(VgmHeader)];


                    Marshal.Copy(new IntPtr(&header), headerBytes, 0, headerBytes.Length);
                    file.Write(headerBytes, 0, headerBytes.Length);

                    //ExtraHeader
                    file.Write(BitConverter.GetBytes(0x0000000c), 0, 4); //extra header size 12bit
                    file.Write(BitConverter.GetBytes(0x00000000), 0, 4); //extra clock offset
                    file.Write(BitConverter.GetBytes(0x00000004), 0, 4); //extra volume offset
                    file.Write(BitConverter.GetBytes(0x04), 0, 1); //chip amount

                    file.Write(BitConverter.GetBytes(0x01), 0, 1); //chip id ym2314
                    file.Write(BitConverter.GetBytes(0x80), 0, 1); // flags VRC7
                    file.Write(BitConverter.GetBytes(0x0800), 0, 2); //volume bit 7 for absolute 8.8 fixed point

                    file.Write(BitConverter.GetBytes(0x12), 0, 1); //chip id ym2149
                    file.Write(BitConverter.GetBytes(0x00), 0, 1); // flags
                    file.Write(BitConverter.GetBytes(0x8200), 0, 2); //volume bit 7 for absolute 8.8 fixed point

                    file.Write(BitConverter.GetBytes(0x07), 0, 1); //chip id ym2608
                    file.Write(BitConverter.GetBytes(0x00), 0, 1); // flags
                    file.Write(BitConverter.GetBytes(0x0140), 0, 2); //volume bit 7 for absolute 8.8 fixed point

                    file.Write(BitConverter.GetBytes(0x87), 0, 1); //chip id ym2608ssg
                    file.Write(BitConverter.GetBytes(0x00), 0, 1); // flags
                    file.Write(BitConverter.GetBytes(0x8140), 0, 2); //volume bit 7 for absolute 8.8 fixed point


                    //sampledata
                    file.Write(BitConverter.GetBytes(0x67), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x66), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xC2), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(sampleData.Length+2), 0, sizeof(int));
                    file.Write(BitConverter.GetBytes(0xc000), 0, sizeof(short));
                    file.Write(sampleData, 0, sampleData.Length);


                    var sr = new StreamWriter(file);
                    // So lame.
                    int chipData = 0;
                    frameNumber = 0;
                    //Inits
                    //2a03
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x15), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x0f), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x08), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x80), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x0f), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x00), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x00), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x30), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x04), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x30), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x0c), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x30), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x01), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x08), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0xB4), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x05), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x08), 0, sizeof(byte));
                    //s5b
                    file.Write(BitConverter.GetBytes(0xA0), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x07), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x38), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x56), 0, sizeof(byte));
                    //epsm
                    file.Write(BitConverter.GetBytes(0x07), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x38), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x56), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x29), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x80), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x56), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x27), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x00), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x56), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x11), 0, sizeof(byte));
                    file.Write(BitConverter.GetBytes(0x37), 0, sizeof(byte));
                    foreach (var reg in writes)
                    {
                        while (frameNumber < reg.FrameNumber)
                        {
                            frameNumber++;
                            file.Write(BitConverter.GetBytes(0x62), 0, sizeof(byte));
                        }
                        if (reg.Register == 0x401c)
                        {
                            chipData = reg.Value;
                        }
                        else if (reg.Register == 0x401e)
                        {
                            chipData = reg.Value;
                        }
                        else if (reg.Register == 0x9010)
                        {
                            chipData = reg.Value;
                        }
                        else if (reg.Register == 0xC000)
                        {
                            chipData = reg.Value;
                        }
                        else if (reg.Register == 0x401d)
                        {
                            file.Write(BitConverter.GetBytes(0x56), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(chipData), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(reg.Value), 0, sizeof(byte));
                        }
                        else if (reg.Register == 0x401f)
                        {
                            file.Write(BitConverter.GetBytes(0x57), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(chipData), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(reg.Value), 0, sizeof(byte));
                        }
                        else if (reg.Register == 0x9030)
                        {
                            file.Write(BitConverter.GetBytes(0x51), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(chipData), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(reg.Value), 0, sizeof(byte));
                        }
                        else if (reg.Register == 0xE000)
                        {
                            file.Write(BitConverter.GetBytes(0xA0), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(chipData), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(reg.Value), 0, sizeof(byte));
                        }
                        else if ((reg.Register < 0x401c) || (reg.Register < 0x409f && reg.Register > 0x401F))
                        {
                            file.Write(BitConverter.GetBytes(0xb4), 0, sizeof(byte));
                            if ((reg.Register <= 0x401F) || (reg.Register <= 0x407f && reg.Register >= 0x4040))
                                file.Write(BitConverter.GetBytes(reg.Register & 0xFF), 0, sizeof(byte));
                            else if (reg.Register >= 0x4080)
                                file.Write(BitConverter.GetBytes((reg.Register - 0x60) & 0xFF), 0, sizeof(byte));
                            else if (reg.Register == 0x4023)
                                file.Write(BitConverter.GetBytes(0x3F), 0, sizeof(byte));
                            file.Write(BitConverter.GetBytes(reg.Value), 0, sizeof(byte));
                        }
                    }
                    file.Write(BitConverter.GetBytes(0x66), 0, sizeof(byte));

                    for (int i = 0; i < gd3.Length; i++)
                    {
                        file.Write(BitConverter.GetBytes(gd3[i]), 0, sizeof(byte));
                    }
                    file.Write(BitConverter.GetBytes(0x00000100), 0, sizeof(uint)); //version

                    file.Write(BitConverter.GetBytes(gd3Lenght), 0, sizeof(uint)); //gd3Lenght
                    for (int i = 0; i < songName.Length; i++)
                    {
                        file.Write(BitConverter.GetBytes(songName[i]), 0, sizeof(byte));
                        file.Write(BitConverter.GetBytes(0), 0, sizeof(byte));
                    }
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    for (int i = 0; i < gameName.Length; i++)
                    {
                        file.Write(BitConverter.GetBytes(gameName[i]), 0, sizeof(byte));
                        file.Write(BitConverter.GetBytes(0), 0, sizeof(byte));
                    }
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    for (int i = 0; i < systemName.Length; i++)
                    {
                        file.Write(BitConverter.GetBytes(systemName[i]), 0, sizeof(byte));
                        file.Write(BitConverter.GetBytes(0), 0, sizeof(byte));
                    }
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    for (int i = 0; i < author.Length; i++)
                    {
                        file.Write(BitConverter.GetBytes(author[i]), 0, sizeof(byte));
                        file.Write(BitConverter.GetBytes(0), 0, sizeof(byte));
                    }
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    file.Write(BitConverter.GetBytes(0), 0, sizeof(short));
                    sr.Flush();
                    sr.Close();
                }
                else
                {
                    var sr = new StreamWriter(file);
                    // So lame.
                    int frameNumber = 0;
                    int chipData = 0;
                    sr.WriteLine("WAITFRAME = 1");
                    sr.WriteLine("APU_WRITE = 2");
                    sr.WriteLine("EPSM_A0_WRITE = 3");
                    sr.WriteLine("EPSM_A1_WRITE = 4");
                    sr.WriteLine("S5B_WRITE = 5");
                    sr.WriteLine("VRC7_WRITE = 6");
                    sr.WriteLine("N163_WRITE = 7");
                    sr.WriteLine("LOOP_VGM = 8");
                    sr.WriteLine("STOP_VGM = 9");
                    sr.WriteLine("MMC5_WRITE = 10");
                    sr.WriteLine(".byte APU_WRITE, $08, $15, $0f, $08, $80, $0f, $00, $00, $30, $04, $30, $0c, $30, $01, $08, $05, $08");
                    sr.WriteLine(".byte EPSM_A0_WRITE, $01, $07, $38");
                    sr.WriteLine(".byte EPSM_A0_WRITE, $04, $07, $38, $29, $80, $27, $00, $11, $37");
                    string writeByteStream = "";
                    string writeCommandByte = ";start";
                    int lastReg = 0;
                    int repeatingReg = 0;
                    foreach (var reg in writes)
                    {
                        if (frameNumber < reg.FrameNumber)
                        {
                            if (lastReg != 0)
                            {
                                sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeByteStream = "";
                                writeCommandByte = ";start";
                                repeatingReg = 0;
                            }
                            while (frameNumber < reg.FrameNumber)
                            {
                                frameNumber++;
                                repeatingReg++;
                            }
                            sr.WriteLine($".byte WAITFRAME, ${repeatingReg:X2}");
                            lastReg = 0;
                            repeatingReg = 0;
                        }
                        if ((reg.Register == 0x401c) || (reg.Register == 0x401e) || (reg.Register == 0x9010) || (reg.Register == 0xC000) || (reg.Register == 0xF800))
                        {
                            chipData = reg.Value;
                        }
                        if (reg.Register == 0x401d)
                        {
                            if (lastReg == reg.Register && repeatingReg < 255)
                            {
                                writeByteStream = writeByteStream + $", ${chipData:X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if(lastReg!=0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte EPSM_A0_WRITE,";
                                writeByteStream = $", ${chipData:X2}, ${reg.Value:X2}";
                                lastReg = reg.Register;
                                repeatingReg = 1;
                            }
                        }
                        else if (reg.Register == 0x401f)
                        {
                            if (lastReg == reg.Register && repeatingReg < 255)
                            {
                                writeByteStream = writeByteStream + $", ${chipData:X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if (lastReg != 0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte EPSM_A1_WRITE,";
                                writeByteStream = $", ${chipData:X2}, ${reg.Value:X2}";
                                lastReg = reg.Register;
                                repeatingReg = 1;
                            }
                        }
                        else if (reg.Register == 0x9030)
                        {
                            if (lastReg == reg.Register && repeatingReg < 255)
                            {
                                writeByteStream = writeByteStream + $", ${chipData:X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if (lastReg != 0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte VRC7_WRITE,";
                                writeByteStream = $", ${chipData:X2}, ${reg.Value:X2}";
                                lastReg = reg.Register;
                                repeatingReg = 1;
                            }
                        }
                        else if (reg.Register == 0xE000)
                        {
                            if (lastReg == reg.Register && repeatingReg < 255)
                            {
                                writeByteStream = writeByteStream + $", ${chipData:X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if (lastReg != 0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte S5B_WRITE,";
                                writeByteStream = $", ${chipData:X2}, ${reg.Value:X2}";
                                lastReg = reg.Register;
                                repeatingReg = 1;
                            }
                        }
                        else if (reg.Register == 0x4800)
                        {
                            if (lastReg == reg.Register && repeatingReg < 255)
                            {
                                writeByteStream = writeByteStream + $", ${chipData:X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if (lastReg != 0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte N163_WRITE,";
                                writeByteStream = $", ${chipData:X2}, ${reg.Value:X2}";
                                lastReg = reg.Register;
                                repeatingReg = 1;
                            }
                        }
                        else if ((reg.Register <= 0x401B) || (reg.Register <= 0x407f && reg.Register >= 0x4040))
                        {
                            if (lastReg == 0x2a03)
                            {
                                writeByteStream = writeByteStream + $", ${(reg.Register & 0xff):X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if (lastReg != 0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte APU_WRITE,";
                                writeByteStream = $", ${(reg.Register & 0xff):X2}, ${reg.Value:X2}";
                                lastReg = 0x2a03;
                                repeatingReg = 1;
                            }
                        }
                        else if (reg.Register >= 0x5000 && reg.Register <= 0x5020)
                        {
                            if (lastReg == 0x5000)
                            {
                                writeByteStream = writeByteStream + $", ${(reg.Register & 0xff):X2}, ${reg.Value:X2}";
                                repeatingReg++;
                            }
                            else
                            {
                                if (lastReg != 0)
                                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                                writeCommandByte = ".byte MMC5_WRITE,";
                                writeByteStream = $", ${(reg.Register & 0xff):X2}, ${reg.Value:X2}";
                                lastReg = 0x5000;
                                repeatingReg = 1;
                            }
                        }
                    }
                    sr.WriteLine(writeCommandByte + $"${repeatingReg:X2}" + writeByteStream);
                    sr.WriteLine(".byte STOP_VGM");
                    sr.WriteLine($" .segment \"DPCM\"");
                    var i = 0;
                    string dpcmData = "";
                    foreach(var sample in sampleData)
                    {
                        i++;
                        dpcmData = dpcmData + " $" + $"{sample:X2}";
                        if ((i % 8) != 0)
                            dpcmData = dpcmData + ",";
                        if ((i % 8) == 0)
                        {
                            sr.WriteLine($" .byte " + dpcmData);
                            dpcmData = "";
                        }

                    }
                    if ((i % 8) != 0)
                    {
                        sr.WriteLine($" .db" + dpcmData);
                    }

                    sr.WriteLine($" ;end of file");
                    sr.Flush();
                    sr.Close();
                }
            }
        }

        private Song song;
        private Project project;
        private ChannelState[] channelStates;
        private bool preserveDpcmPadding;
        private readonly int[] DPCMOctaveOrder = new[] { 4, 5, 3, 6, 2, 7, 1, 0 };

        int[] apuRegister = new int[0xff];
        int[] vrc7Register = new int[0xff];
        int[] vrc7Trigger = new int[0x6];
        int[] epsmRegisterLo = new int[0xff];
        int[] epsmRegisterHi = new int[0xff];
        int[] epsmFmTrigger = new int[0x6];
        int[] epsmFmEnabled = new int[0x6];
        int[] epsmFmKey = new int[0x6];
        int[] epsmFmRegisterOrder = new[] { 0xB0, 0xB4, 0x30, 0x40, 0x50, 0x60, 0x70, 0x80, 0x90, 0x38, 0x48, 0x58, 0x68, 0x78, 0x88, 0x98, 0x34, 0x44, 0x54, 0x64, 0x74, 0x84, 0x94, 0x3c, 0x4c, 0x5c, 0x6c, 0x7c, 0x8c, 0x9c, 0x22 };
        int[] s5bRegister = new int[0xff];
        bool dpcmTrigger = false;
        byte[] dpcmData = new byte[0xffff];
        byte[] pcmRAMData = new byte[0xffffff];
        bool ym2149AsEPSM;
        int[] NOISE_FREQ_TABLE = new[] {0x004,0x008,0x010,0x020,0x040,0x060,0x080,0x0A0,0x0CA,0x0FE,0x17C,0x1FC,0x2FA,0x3F8,0x7F2,0xFE4 };
        float[] clockMultiplier = new float[ExpansionType.Count];

        class ChannelState
        {
            public const int Triggered = 1;
            public const int Released = 2;
            public const int Stopped = 0;

            public int period = -1;
            public int note = 0;
            public int pitch = 0;
            public int volume = 15;
            public int octave = -1;
            public int state = Stopped;
            public int dmc = 0;

            public int fdsModDepth = 0;
            public int fdsModSpeed = 0;

            public bool fmTrigger = false;
            public bool fmSustain = false;

            public Instrument instrument = null;
        };

        public int GetBestMatchingNote(int period, ushort[] noteTable, out int finePitch)
        {
            int bestNote = -1;
            int minDiff = 9999999;

            for (int i = 0; i < noteTable.Length; i++)
            {
                var diff = Math.Abs(noteTable[i] - period);
                if (diff < minDiff)
                {
                    minDiff = diff;
                    bestNote = i;
                }
            }

            finePitch = period - noteTable[bestNote];

            return bestNote;
        }

        private Pattern GetOrCreatePattern(Channel channel, int patternIdx)
        {
            if (channel.PatternInstances[patternIdx] == null)
                channel.PatternInstances[patternIdx] = channel.CreatePattern();
            return channel.PatternInstances[patternIdx];
        }

        private Instrument GetDutyInstrument(Channel channel, int duty)
        {
            var expansion = channel.Expansion;
            var expPrefix = expansion == ExpansionType.None || expansion == ExpansionType.Mmc5 ? "" : ExpansionType.InternalNames[expansion] + " ";
            var name = $"{expPrefix}Duty {duty}";

            var instrument = project.GetInstrument(name);
            if (instrument == null)
            {
                instrument = project.CreateInstrument(expansion, name);
                instrument.Envelopes[EnvelopeType.DutyCycle].Length = 1;
                instrument.Envelopes[EnvelopeType.DutyCycle].Values[0] = (sbyte)duty;
            }

            if (expansion == ExpansionType.Vrc6)
                instrument.Vrc6SawMasterVolume = Vrc6SawMasterVolumeType.Full;

            return instrument;
        }

        private Instrument GetFdsInstrument(sbyte[] wavEnv, sbyte[] modEnv, byte masterVolume)
        {
            foreach (var inst in project.Instruments)
            {
                if (inst.IsFds)
                {
                    if (inst.FdsMasterVolume == masterVolume &&
                        wavEnv.SequenceEqual(inst.Envelopes[EnvelopeType.FdsWaveform].Values.Take(64)) &&
                        modEnv.SequenceEqual(inst.Envelopes[EnvelopeType.FdsModulation].Values.Take(32)))
                    {
                        return inst;
                    }
                }
            }

            for (int i = 1; ; i++)
            {
                var name = $"FDS {i}";
                if (project.IsInstrumentNameUnique(name))
                {
                    var instrument = project.CreateInstrument(ExpansionType.Fds, name);

                    Array.Copy(wavEnv, instrument.Envelopes[EnvelopeType.FdsWaveform].Values, 64);
                    Array.Copy(modEnv, instrument.Envelopes[EnvelopeType.FdsModulation].Values, 32);

                    instrument.FdsMasterVolume = masterVolume;
                    instrument.FdsWavePreset = WavePresetType.Custom;
                    instrument.FdsModPreset = WavePresetType.Custom;

                    return instrument;
                }
            }
        }

        private Instrument GetVrc7Instrument(byte patch, byte[] patchRegs)
        {
            if (patch == Vrc7InstrumentPatch.Custom)
            {
                // Custom instrument, look for a match.
                foreach (var inst in project.Instruments)
                {
                    if (inst.IsVrc7)
                    {
                        if (inst.Vrc7Patch == 0 && inst.Vrc7PatchRegs.SequenceEqual(patchRegs))
                            return inst;
                    }
                }

                for (int i = 1; ; i++)
                {
                    var name = $"VRC7 Custom {i}";
                    if (project.IsInstrumentNameUnique(name))
                    {
                        var instrument = project.CreateInstrument(ExpansionType.Vrc7, name);
                        instrument.Vrc7Patch = patch;
                        Array.Copy(patchRegs, instrument.Vrc7PatchRegs, 8);
                        return instrument;
                    }
                }
            }
            else
            {
                // Built-in patch, simply find by name.
                var name = $"VRC7 {Instrument.GetVrc7PatchName(patch)}";
                var instrument = project.GetInstrument(name);

                if (instrument == null)
                {
                    instrument = project.CreateInstrument(ExpansionType.Vrc7, name);
                    instrument.Vrc7Patch = patch;
                }

                return instrument;
            }
        }

        private Instrument GetS5BInstrument(int noise, int mixer)
        {
            var name = "S5B";
            if (mixer != 2 && noise == 0)
                noise = 1;
            if (mixer != 2)
                name = $"S5B Noise {noise} M {mixer}";

            var instrument = project.GetInstrument(name);
            if (instrument == null)
            {
                instrument = project.CreateInstrument(ExpansionType.S5B, name);
                instrument.Envelopes[EnvelopeType.YMNoiseFreq].Length = 1;
                instrument.Envelopes[EnvelopeType.YMNoiseFreq].Values[0] = (sbyte)noise;
                instrument.Envelopes[EnvelopeType.YMMixerSettings].Length = 1;
                instrument.Envelopes[EnvelopeType.YMMixerSettings].Values[0] = (sbyte)mixer;
            }

            return instrument;

        }

        private Instrument GetDPCMInstrument()
        {
            var inst = project.GetInstrument($"DPCM Instrument");

            if (inst == null)
                return project.CreateInstrument(ExpansionType.None, "DPCM Instrument");
            if (inst.SamplesMapping.Count < (Note.MusicalNoteMax - Note.MusicalNoteMin + 1))
                return inst;

            for (int i = 1; ; i++)
            {
                inst = project.GetInstrument($"DPCM Instrument {i}");

                if (inst == null)
                    return project.CreateInstrument(ExpansionType.None, $"DPCM Instrument {i}");
                if (inst.SamplesMapping.Count < (Note.MusicalNoteMax - Note.MusicalNoteMin + 1))
                    return inst;
            }
        }

        private Instrument GetEPSMInstrument(byte chanType, byte[] patchRegs, int noise, int mixer)
        {
            var name = $"EPSM {Instrument.GetEpsmPatchName(1)}";
            var instrument = project.GetInstrument(name);
            var stereo = "";
            if (patchRegs[1] == 0x80)
                stereo = " Left";
            if (patchRegs[1] == 0x40)
                stereo = " Right";
            if (patchRegs[1] == 0x00 && chanType == 2)
                stereo = " Stop";
            if (patchRegs[1] == 0x00 && chanType != 2)
                patchRegs[1] = 0x80;

            if (chanType == 0)
            {
                if (mixer != 2 && noise == 0)
                    noise = 1;
                if (mixer != 2)
                    name = $"EPSM Noise {noise} M {mixer}";

                instrument = project.GetInstrument(name);
                if (instrument == null)
                {
                    instrument = project.CreateInstrument(ExpansionType.EPSM, name);

                    instrument.EpsmPatch = 1;
                    instrument.Envelopes[EnvelopeType.YMNoiseFreq].Length = 1;
                    instrument.Envelopes[EnvelopeType.YMNoiseFreq].Values[0] = (sbyte)noise;
                    instrument.Envelopes[EnvelopeType.YMMixerSettings].Length = 1;
                    instrument.Envelopes[EnvelopeType.YMMixerSettings].Values[0] = (sbyte)mixer;
                }
                return instrument;
            }

            if (chanType == 2)
            {
                name = $"EPSM Drum{stereo}";
                instrument = project.GetInstrument(name);
                if (instrument == null)
                {
                    instrument = project.CreateInstrument(ExpansionType.EPSM, name);

                    instrument.EpsmPatch = 0;
                    Array.Copy(EpsmInstrumentPatch.Infos[EpsmInstrumentPatch.Default].data, instrument.EpsmPatchRegs, 31);
                    instrument.EpsmPatchRegs[1] = patchRegs[1];
                }
                return instrument;
            }

            foreach (var inst in project.Instruments)
            {
                if (inst.IsEpsm)
                {
                    if (inst.EpsmPatchRegs.SequenceEqual(patchRegs))
                        return inst;
                }
            }

            for (int i = 1; ; i++)
            {
                name = $"EPSM Custom{stereo} {i}";
                if (project.IsInstrumentNameUnique(name))
                {
                    instrument = project.CreateInstrument(ExpansionType.EPSM, name);
                    instrument.EpsmPatch = 0;
                    Array.Copy(patchRegs, instrument.EpsmPatchRegs, 31);
                    return instrument;
                }
            }
            foreach (var inst in project.Instruments)
            {
                if (inst.IsEpsm)
                    return inst;
            }
        }


        private int GetState(int channel, int state, int sub)
        {
            switch (channel)
            {
                case ChannelType.Square1:
                case ChannelType.Square2:
                    {
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return (int)apuRegister[2+(channel*4)] + (int)((apuRegister[3+(channel*4)] & 0x7) << 8);
                            case NotSoFatso.STATE_DUTYCYCLE: return (int)(apuRegister[2 + (channel * 4)] & 0xc0) >> 6;
                            //case NotSoFatso.STATE_VOLUME: return mWave_Squares.nLengthCount[channel] && mWave_Squares.bChannelEnabled[channel] ? mWave_Squares.nVolume[channel] : 0;
                            case NotSoFatso.STATE_VOLUME: return (apuRegister[(channel * 4)] & 0xf);
                        }
                        break;
                    }
                case ChannelType.Triangle:
                    {
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return (int)apuRegister[2 + (channel * 4)] + (int)((apuRegister[3 + (channel * 4)] & 0x7) << 8);
                            //case NotSoFatso.STATE_VOLUME: return mWave_TND.nTriLengthCount && mWave_TND.bTriChannelEnabled ? mWave_TND.nTriLinearCount : 0;
                            case NotSoFatso.STATE_VOLUME: return (apuRegister[(channel * 4)] & 0xf);
                        }
                        break;
                    }
                case ChannelType.Noise:
                    {
                        switch (state)
                        {
                            case NotSoFatso.STATE_VOLUME: return (apuRegister[(channel * 4)] & 0xf);
                            //case NotSoFatso.STATE_VOLUME: return mWave_TND.nNoiseLengthCount && mWave_TND.bNoiseChannelEnabled ? mWave_TND.nNoiseVolume : 0;
                            case NotSoFatso.STATE_DUTYCYCLE: return (apuRegister[0x0e] & 0x80) >> 8;

                            //case NotSoFatso.STATE_PERIOD: return NOISE_FREQ_TABLE[apuRegister[0x0e]&0xf];
                            case NotSoFatso.STATE_PERIOD: return apuRegister[0x0e] & 0xf;
                                //case NotSoFatso.STATE_PERIOD: return IndexOf(NOISE_FREQ_TABLE, 16, mWave_TND.nNoiseFreqTimer);
                        }
                        break;
                    }
                case ChannelType.Dpcm:
                    {
                        switch (state)
                        {
                            /*case NotSoFatso.STATE_DPCMSAMPLELENGTH:
                                {
                                    if (mWave_TND.bDMCTriggered)
                                    {
                                        mWave_TND.bDMCTriggered = 0;
                                        return mWave_TND.nDMCLength;
                                    }
                                    else
                                    {
                                        return 0;
                                    }
                                }*/
                            case NotSoFatso.STATE_DPCMSAMPLELENGTH:
                                {
                                    if (dpcmTrigger)
                                    {
                                        Log.LogMessage(LogSeverity.Info, "samplelength: " + (apuRegister[0x13] << 4) + " sampladdr: " + (apuRegister[0x12] << 6));
                                        dpcmTrigger = false;

                                        return (apuRegister[0x13] << 4) + 1;
                                    }
                                    else
                                    {
                                        return 0;
                                    }
                                }/*
                            case NotSoFatso.STATE_DPCMSAMPLEADDR:
                                {
                                    return mWave_TND.nDMCDMABank_Load << 16 | mWave_TND.nDMCDMAAddr_Load;
                                }*/
                            case NotSoFatso.STATE_DPCMSAMPLEADDR:
                                {
                                    return apuRegister[0x12];
                                }
                            case NotSoFatso.STATE_DPCMLOOP:
                                {
                                    return apuRegister[0x10] & 0x40;
                                }/*
                            case NotSoFatso.STATE_DPCMPITCH:
                                {
                                    return IndexOf(DMC_FREQ_TABLE[bPALMode], 0x10, mWave_TND.nDMCFreqTimer);
                                }*/
                            case NotSoFatso.STATE_DPCMPITCH:
                                {
                                    return apuRegister[0x10] & 0x0f;
                                }/*
                            case NotSoFatso.STATE_DPCMSAMPLEDATA:
                                {
                                    int bank = mWave_TND.nDMCDMABank_Load;
                                    int addr = mWave_TND.nDMCDMAAddr_Load + sub;
                                    if (addr & 0x1000)
                                    {
                                        addr &= 0x0FFF;
                                        bank = (bank + 1) & 0x07;
                                    }
                                    return mWave_TND.pDMCDMAPtr[bank][addr];
                                }*/
                            case NotSoFatso.STATE_DPCMSAMPLEDATA:
                                {
                                    return dpcmData[((apuRegister[0x12] << 6)) + sub];
                                }
                            case NotSoFatso.STATE_DPCMCOUNTER:
                                {
                                    return 0;// mWave_TND.bDMCLastDeltaWrite;
                                }
                            case NotSoFatso.STATE_DPCMACTIVE:
                                {
                                    return apuRegister[0x15] & 0x10;// mWave_TND.bDMCActive;
                                }
                        }
                        break;
                    }

                //###############################################################
                //
                // VRC6 is not supported by the VGM Standard
                //
                //###############################################################
/*                case ChannelType.Vrc6Square1:
                case ChannelType.Vrc6Square2:
                    {
                        int idx = channel - ChannelType.Vrc6Square1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return mWave_VRC6Pulse[idx].nFreqTimer.W;
                            case NotSoFatso.STATE_DUTYCYCLE: return mWave_VRC6Pulse[idx].nDutyCycle;
                            case NotSoFatso.STATE_VOLUME: return mWave_VRC6Pulse[idx].bChannelEnabled ? mWave_VRC6Pulse[idx].nVolume : 0;
                        }
                        break;
                    }
                case ChannelType.Vrc6Saw:
                    {
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return mWave_VRC6Saw.nFreqTimer.W;
                            case NotSoFatso.STATE_VOLUME: return mWave_VRC6Saw.bChannelEnabled ? mWave_VRC6Saw.nAccumRate : 0;
                        }
                        break;
                    }
                case ChannelType.FdsWave:
                    {
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return mWave_FDS.nFreq.W;
                            case NotSoFatso.STATE_VOLUME: return mWave_FDS.bEnabled ? mWave_FDS.nVolume : 0;
                            case NotSoFatso.STATE_FDSWAVETABLE: return mWave_FDS.nWaveTable[sub];
                            case NotSoFatso.STATE_FDSMODULATIONTABLE: return mWave_FDS.nLFO_Table[sub * 2];
                            case NotSoFatso.STATE_FDSMODULATIONDEPTH: return mWave_FDS.bLFO_On && (mWave_FDS.nSweep_Mode & 2) ? mWave_FDS.nSweep_Gain : 0;
                            case NotSoFatso.STATE_FDSMODULATIONSPEED: return mWave_FDS.bLFO_On ? mWave_FDS.nLFO_Freq.W : 0;
                            case NotSoFatso.STATE_FDSMASTERVOLUME: return mWave_FDS.nMainVolume;
                        }
                        break;
                    }*/
                case ChannelType.Vrc7Fm1:
                case ChannelType.Vrc7Fm2:
                case ChannelType.Vrc7Fm3:
                case ChannelType.Vrc7Fm4:
                case ChannelType.Vrc7Fm5:
                case ChannelType.Vrc7Fm6:
                    {
                        int idx = channel - ChannelType.Vrc7Fm1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return ((vrc7Register[0x20+idx] & 1) << 8) | (vrc7Register[0x10 + idx]);
                            case NotSoFatso.STATE_VOLUME: return (vrc7Register[0x30 + idx] >> 0) & 0xF;
                            case NotSoFatso.STATE_VRC7PATCH: return (vrc7Register[0x30 + idx] >> 4) & 0xF;
                            case NotSoFatso.STATE_FMPATCHREG: return (vrc7Register[sub]);
                            case NotSoFatso.STATE_FMOCTAVE: return (vrc7Register[0x20 + idx] >> 1) & 0x07;
                            case NotSoFatso.STATE_FMTRIGGER: return (vrc7Register[0x20 + idx] >> 4) & 0x01;
                            case NotSoFatso.STATE_FMTRIGGERCHANGE:
                                int trigger = vrc7Trigger[idx];
                                vrc7Trigger[idx] = 0;
                                return trigger;
                            case NotSoFatso.STATE_FMSUSTAIN: return (vrc7Register[0x20 + idx] >> 5) & 0x01;
                        }
                        break;
                    }
                //###############################################################
                //
                // MMC5 and N163 is not supported by the VGM Standard
                //
                //###############################################################
                    /*
                case ChannelType.Mmc5Square1:
                case ChannelType.Mmc5Square2:
                    {
                        int idx = channel - ChannelType.Mmc5Square1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return mWave_MMC5Square[idx].nFreqTimer.W;
                            case NotSoFatso.STATE_DUTYCYCLE: return IndexOf(DUTY_CYCLE_TABLE, 4, mWave_MMC5Square[idx].nDutyCycle);
                            case NotSoFatso.STATE_VOLUME: return mWave_MMC5Square[idx].nLengthCount && mWave_MMC5Square[idx].bChannelEnabled ? mWave_MMC5Square[idx].nVolume : 0;
                        }
                        break;
                    }
                case ChannelType.N163Wave1:
                case ChannelType.N163Wave2:
                case ChannelType.N163Wave3:
                case ChannelType.N163Wave4:
                case ChannelType.N163Wave5:
                case ChannelType.N163Wave6:
                case ChannelType.N163Wave7:
                case ChannelType.N163Wave8:
                    {
                        int idx = 7 - (channel - ChannelType.N163Wave1);
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return mWave_N106.nFreqReg[idx].D;
                            case NotSoFatso.STATE_VOLUME: return mWave_N106.nVolume[idx];
                            case NotSoFatso.STATE_N163WAVEPOS: return mWave_N106.nWavePosStart[idx];
                            case NotSoFatso.STATE_N163WAVESIZE: return mWave_N106.nWaveSize[idx];
                            case NotSoFatso.STATE_N163WAVE: return mWave_N106.nRAM[sub];
                            case NotSoFatso.STATE_N163NUMCHANNELS: return mWave_N106.nActiveChannels + 1;
                        }
                        break;
                    }*/
                case ChannelType.S5BSquare1:
                case ChannelType.S5BSquare2:
                case ChannelType.S5BSquare3:
                    {
                        int idx = channel - ChannelType.S5BSquare1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return s5bRegister[0 + idx * 2] | (s5bRegister[1 + idx * 2] << 8);
                            case NotSoFatso.STATE_VOLUME: return (((s5bRegister[7] >> idx) & 9) != 9) ? s5bRegister[8 + idx] : 0;
                            case NotSoFatso.STATE_YMMIXER: return ((s5bRegister[7] >> idx) & 9);
                            case NotSoFatso.STATE_YMNOISEFREQUENCY: return s5bRegister[6];
                        }
                        break;
                    }

                case ChannelType.EPSMrythm1:
                case ChannelType.EPSMrythm2:
                case ChannelType.EPSMrythm3:
                case ChannelType.EPSMrythm4:
                case ChannelType.EPSMrythm5:
                case ChannelType.EPSMrythm6:
                    {
                        int idx = channel - ChannelType.EPSMrythm1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_STEREO: return (epsmRegisterLo[0x18+idx] & 0xc0);
                            case NotSoFatso.STATE_PERIOD: return 0xc20;
                            case NotSoFatso.STATE_VOLUME:
                                int returnval = (epsmRegisterLo[0x10] & (1 << idx)) != 0 ? ((epsmRegisterLo[0x18 + idx] & 0x0f) >> 1) : 0;
                                epsmRegisterLo[0x10] = ~(~epsmRegisterLo[0x10] | 1 << idx);
                                return returnval;
                        }
                        break;
                    }
                case ChannelType.EPSMSquare1:
                case ChannelType.EPSMSquare2:
                case ChannelType.EPSMSquare3:
                    {
                        int idx = channel - ChannelType.EPSMSquare1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_PERIOD: return epsmRegisterLo[0 + idx*2] | (epsmRegisterLo[1 + idx * 2] << 8);
                            case NotSoFatso.STATE_VOLUME: return (((epsmRegisterLo[7] >> idx) & 9 ) != 9)  ? epsmRegisterLo[8 + idx] : 0;
                            case NotSoFatso.STATE_YMMIXER: return ((epsmRegisterLo[7] >> idx) & 9);
                            case NotSoFatso.STATE_YMNOISEFREQUENCY: return epsmRegisterLo[6];
                        }
                        break;
                    }
                case ChannelType.EPSMFm1:
                case ChannelType.EPSMFm2:
                case ChannelType.EPSMFm3:
                case ChannelType.EPSMFm4:
                case ChannelType.EPSMFm5:
                case ChannelType.EPSMFm6:
                    {
                        int idx = channel - ChannelType.EPSMFm1;
                        switch (state)
                        {
                            case NotSoFatso.STATE_FMTRIGGER:
                                {
                                    int trigger = epsmFmTrigger[idx];
                                    epsmFmTrigger[idx] = 0;
                                    return trigger;
                                }
                            case NotSoFatso.STATE_FMOCTAVE:
                                if (idx < 3)
                                    return (epsmRegisterLo[0xa4 + idx] >> 3) & 0x07;
                                else
                                    return (epsmRegisterHi[0xa4 + idx - 3] >> 3) & 0x07;
                            case NotSoFatso.STATE_PERIOD:
                                if (idx < 3)
                                    return (epsmRegisterLo[0xa0+idx] + ((epsmRegisterLo[0xa4 + idx] & 7) << 8)) / 4;
                                else
                                    return (epsmRegisterHi[0xa0 + idx-3] + ((epsmRegisterHi[0xa4 + idx-3] & 7) << 8)) / 4;
                            case NotSoFatso.STATE_VOLUME:
                                if(idx < 3)
                                    return (epsmRegisterLo[0xb4 + idx] & 0xc0) > 0 ? 15 : 0;
                                else
                                    return (epsmRegisterHi[0xb4 + idx-3] & 0xc0) > 0 ? 15 : 0;
                            case NotSoFatso.STATE_FMSUSTAIN: return epsmFmEnabled[idx] > 0 ? 1 : 0;
                            case NotSoFatso.STATE_FMPATCHREG:
                                int returnval = idx < 3 ? epsmRegisterLo[epsmFmRegisterOrder[sub] + idx] : epsmRegisterHi[epsmFmRegisterOrder[sub] + idx - 3];
                                if (sub == 3 && (epsmFmKey[idx] & 0x10) == 0)
                                {
                                    returnval = 0x7f;
                                }
                                if (sub == 10 && (epsmFmKey[idx] & 0x20) == 0)
                                {
                                    returnval = 0x7f;
                                }
                                if (sub == 17 && (epsmFmKey[idx] & 0x40) == 0)
                                {
                                    returnval = 0x7f;
                                }
                                if (sub == 24 && (epsmFmKey[idx] & 0x80) == 0)
                                {
                                    returnval = 0x7f;
                                }
                                return returnval;
                        }
                        break;
                    }
            }

            return 0;
        }



        private bool UpdateChannel(int p, int n, Channel channel, ChannelState state)
        {
            var project = channel.Song.Project;
            var hasNote = false;

            if (channel.Type == ChannelType.Dpcm)
            {
                var dmc = GetState(channel.Type, NotSoFatso.STATE_DPCMCOUNTER, 0);
                var len = GetState(channel.Type, NotSoFatso.STATE_DPCMSAMPLELENGTH, 0);
                var dmcActive = GetState(channel.Type, NotSoFatso.STATE_DPCMACTIVE, 0);

                if (len > 0)
                {
                    // Subtracting one here is not correct. But it is a fact that a lot of games
                    // seemed to favor tight sample packing and did not care about playing one
                    // extra sample of garbage.
                    if (!preserveDpcmPadding)
                    {
                        Debug.Assert((len & 0xf) == 1);
                        len--;
                        Debug.Assert((len & 0xf) == 0);
                    }
                    var sampleData = new byte[len];
                    for (int i = 0; i < len; i++)
                        sampleData[i] = (byte)GetState(channel.Type, NotSoFatso.STATE_DPCMSAMPLEDATA, i);

                    var sample = project.FindMatchingSample(sampleData);
                    if (sample == null)
                        sample = project.CreateDPCMSampleFromDmcData($"Sample {project.Samples.Count + 1}", sampleData);

                    var loop = GetState(channel.Type, NotSoFatso.STATE_DPCMLOOP, 0) != 0;
                    var pitch = GetState(channel.Type, NotSoFatso.STATE_DPCMPITCH, 0);
                    var noteValue = -1;
                    var dpcmInst = (Instrument)null;

                    foreach (var inst in project.Instruments)
                    {
                        if (inst.HasAnyMappedSamples)
                        {
                            noteValue = inst.FindDPCMSampleMapping(sample, pitch, loop);
                            if (noteValue >= 0)
                            {
                                dpcmInst = inst;
                                break;
                            }
                        }
                    }

                    if (noteValue < 0)
                    {
                        dpcmInst = GetDPCMInstrument();

                        var found = false;
                        foreach (var o in DPCMOctaveOrder)
                        {
                            for (var i = 0; i < 12; i++)
                            {
                                noteValue = o * 12 + i + 1;
                                if (dpcmInst.GetDPCMMapping(noteValue) == null)
                                {
                                    found = true;
                                    break;
                                }
                            }

                            if (found)
                                break;
                        }

                        Debug.Assert(found);
                        dpcmInst.MapDPCMSample(noteValue, sample, pitch, loop);
                    }

                    if (Note.IsMusicalNote(noteValue))
                    {
                        var note = GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n);
                        note.Value = (byte)noteValue;
                        note.Instrument = dpcmInst;
                        if (state.dmc != dmc)
                        {
                            note.DeltaCounter = (byte)dmc;
                            state.dmc = dmc;
                        }
                        hasNote = true;
                        state.state = ChannelState.Triggered;
                    }
                }
                else if (dmc != state.dmc)
                {
                    GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n).DeltaCounter = (byte)dmc;
                    state.dmc = dmc;
                }

                if (dmcActive == 0 && state.state == ChannelState.Triggered)
                {
                    GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n).IsStop = true;
                    state.state = ChannelState.Stopped;
                }
            }
            else if (channel.Type != ChannelType.Dpcm)
            {
                var period = GetState(channel.Type, NotSoFatso.STATE_PERIOD, 0);
                var volume = GetState(channel.Type, NotSoFatso.STATE_VOLUME, 0);
                var duty = GetState(channel.Type, NotSoFatso.STATE_DUTYCYCLE, 0);
                var force = false;
                var stop = false;
                var release = false;
                var attack = true;
                var octave = -1;

                // VRC6 has a much larger volume range (6-bit) than our volume (4-bit).
                if (channel.Type == ChannelType.Vrc6Saw)
                {
                    volume >>= 2;
                }
                else if (channel.Type == ChannelType.FdsWave)
                {
                    volume = Math.Min(Note.VolumeMax, volume >> 1);
                }
                else if (channel.Type >= ChannelType.Vrc7Fm1 && channel.Type <= ChannelType.Vrc7Fm6)
                {
                    volume = 15 - volume;
                }

                var hasOctave = channel.IsVrc7Channel || channel.IsEPSMFmChannel;
                var hasVolume = channel.Type != ChannelType.Triangle;
                var hasPitch = channel.Type != ChannelType.Noise && !channel.IsEPSMRythmChannel;
                var hasDuty = channel.Type == ChannelType.Square1 || channel.Type == ChannelType.Square2 || channel.Type == ChannelType.Noise || channel.Type == ChannelType.Vrc6Square1 || channel.Type == ChannelType.Vrc6Square2 || channel.Type == ChannelType.Mmc5Square1 || channel.Type == ChannelType.Mmc5Square2;
                var hasTrigger = channel.IsVrc7Channel;

                if (channel.Type >= ChannelType.Vrc7Fm1 && channel.Type <= ChannelType.Vrc7Fm6)
                {
                    var trigger = GetState(channel.Type, NotSoFatso.STATE_FMTRIGGER, 0) != 0;
                    var sustain = GetState(channel.Type, NotSoFatso.STATE_FMSUSTAIN, 0) != 0;
                    var triggerChange = GetState(channel.Type, NotSoFatso.STATE_FMTRIGGERCHANGE, 0);

                    var newState = state.state;

                    if (!state.fmTrigger && trigger)
                        newState = ChannelState.Triggered;
                    else if (state.fmTrigger && !trigger && sustain)
                        newState = ChannelState.Released;
                    else if (!trigger && !sustain)
                        newState = ChannelState.Stopped;

                    if (newState != state.state || triggerChange > 0)
                    {
                        stop = newState == ChannelState.Stopped;
                        release = newState == ChannelState.Released;
                        state.state = newState;
                        force |= true;
                    }
                    else
                    {
                        attack = false;
                    }

                    octave = GetState(channel.Type, NotSoFatso.STATE_FMOCTAVE, 0);

                    state.fmTrigger = trigger;
                    state.fmSustain = sustain;
                }
                else if (channel.Type >= ChannelType.EPSMFm1 && channel.Type <= ChannelType.EPSMFm6)
                {
                    var trigger = GetState(channel.Type, NotSoFatso.STATE_FMTRIGGER, 0) != 0;
                    var sustain = GetState(channel.Type, NotSoFatso.STATE_FMSUSTAIN, 0) > 0;
                    var stopped = GetState(channel.Type, NotSoFatso.STATE_VOLUME, 0) == 0;

                    var newState = state.state;

                    if (!trigger)
                        attack = false;

                    newState = sustain ? ChannelState.Triggered : (stopped ? ChannelState.Stopped : ChannelState.Released);

                    if (newState != state.state || trigger)
                    {
                        stop = newState == ChannelState.Stopped;
                        release = newState == ChannelState.Released;
                        state.state = newState;
                        force |= true;
                    }

                    octave = GetState(channel.Type, NotSoFatso.STATE_FMOCTAVE, 0);

                    state.fmTrigger = trigger;
                    state.fmSustain = sustain;
                }
                else
                {
                    var newState = volume != 0 && (channel.Type == ChannelType.Noise || period != 0) ? ChannelState.Triggered : ChannelState.Stopped;

                    if (newState != state.state)
                    {
                        stop = newState == ChannelState.Stopped;
                        force |= true;
                        state.state = newState;
                    }
                }

                if (hasVolume)
                {
                    if (state.volume != volume && (volume != 0 || hasTrigger))
                    {
                        var pattern = GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n).Volume = (byte)volume;
                        state.volume = volume;
                    }
                }

                Instrument instrument = null;

                if (hasDuty)
                {
                    instrument = GetDutyInstrument(channel, duty);
                }
                else if (channel.Type == ChannelType.FdsWave)
                {
                    var wavEnv = new sbyte[64];
                    var modEnv = new sbyte[32];

                    for (int i = 0; i < 64; i++)
                        wavEnv[i] = (sbyte)(GetState(channel.Type, NotSoFatso.STATE_FDSWAVETABLE, i) & 0x3f);
                    for (int i = 0; i < 32; i++)
                        modEnv[i] = (sbyte)(GetState(channel.Type, NotSoFatso.STATE_FDSMODULATIONTABLE, i));

                    Envelope.ConvertFdsModulationToAbsolute(modEnv);

                    var masterVolume = (byte)GetState(channel.Type, NotSoFatso.STATE_FDSMASTERVOLUME, 0);

                    instrument = GetFdsInstrument(wavEnv, modEnv, masterVolume);

                    int modDepth = GetState(channel.Type, NotSoFatso.STATE_FDSMODULATIONDEPTH, 0);
                    int modSpeed = GetState(channel.Type, NotSoFatso.STATE_FDSMODULATIONSPEED, 0);

                    if (state.fdsModDepth != modDepth)
                    {
                        var pattern = GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n).FdsModDepth = (byte)modDepth;
                        state.fdsModDepth = modDepth;
                    }

                    if (state.fdsModSpeed != modSpeed)
                    {
                        var pattern = GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n).FdsModSpeed = (ushort)modSpeed;
                        state.fdsModSpeed = modSpeed;
                    }
                }
                /*else if (channel.Type >= ChannelType.N163Wave1 &&
                         channel.Type <= ChannelType.N163Wave8)
                {
                    var wavePos = (byte)GetState(channel.Type, NotSoFatso.STATE_N163WAVEPOS, 0);
                    var waveLen = (byte)GetState(channel.Type, NotSoFatso.STATE_N163WAVESIZE, 0);

                    if (waveLen > 0)
                    {
                        var waveData = new sbyte[waveLen];
                        for (int i = 0; i < waveLen; i++)
                            waveData[i] = (sbyte)GetState(channel.Type, NotSoFatso.STATE_N163WAVE, wavePos + i);

                        instrument = GetN163Instrument(waveData, wavePos);
                    }

                    period >>= 2;
                }*/
                else if (channel.Type >= ChannelType.Vrc7Fm1 &&
                         channel.Type <= ChannelType.Vrc7Fm6)
                {
                    var patch = (byte)GetState(channel.Type, NotSoFatso.STATE_VRC7PATCH, 0);
                    var regs = new byte[8];

                    if (patch == 0)
                    {
                        for (int i = 0; i < 8; i++)
                            regs[i] = (byte)GetState(channel.Type, NotSoFatso.STATE_FMPATCHREG, i);
                    }

                    instrument = GetVrc7Instrument(patch, regs);
                }
                else if (channel.Type >= ChannelType.S5BSquare1 && channel.Type <= ChannelType.S5BSquare3)
                {
                    var noise = (byte)GetState(channel.Type, NotSoFatso.STATE_YMNOISEFREQUENCY, 0);
                    var mixer = (int)GetState(channel.Type, NotSoFatso.STATE_YMMIXER, 0);
                    mixer = (mixer & 0x1) + ((mixer & 0x8) >> 2);
                    instrument = GetS5BInstrument(noise, mixer);
                }
                else if (channel.Type >= ChannelType.EPSMSquare1 && channel.Type <= ChannelType.EPSMrythm6)
                {
                    var regs = new byte[31];
                    Array.Clear(regs, 0, regs.Length);
                    if (channel.Type >= ChannelType.EPSMFm1 && channel.Type <= ChannelType.EPSMFm6)
                    {
                        for (int i = 0; i < 31; i++)
                            regs[i] = (byte)GetState(channel.Type, NotSoFatso.STATE_FMPATCHREG, i);

                        instrument = GetEPSMInstrument(1, regs, 0, 0);
                    }
                    else if (channel.Type >= ChannelType.EPSMrythm1 && channel.Type <= ChannelType.EPSMrythm6)
                    {
                        regs[1] = (byte)GetState(channel.Type, NotSoFatso.STATE_STEREO, 0);
                        instrument = GetEPSMInstrument(2, regs, 0, 0);
                    }
                    else
                    {
                        var noise = (byte)GetState(channel.Type, NotSoFatso.STATE_YMNOISEFREQUENCY, 0);
                        var mixer = (int)GetState(channel.Type, NotSoFatso.STATE_YMMIXER, 0);
                        mixer = (mixer & 0x1) + ((mixer & 0x8) >> 2);
                        instrument = GetEPSMInstrument(0, regs, noise, mixer);
                    }

                }
                else
                {
                    instrument = GetDutyInstrument(channel, 0);
                }

                if(channel.IsEPSMFmChannel || channel.IsVrc7Channel)
                    period = (int)(period * clockMultiplier[channel.Expansion]);
                else if(!channel.IsEPSMRythmChannel)
                    period = (int)(period / clockMultiplier[channel.Expansion]);
                if(ym2149AsEPSM && channel.IsEPSMSquareChannel)
                    period = (int)(period / clockMultiplier[ExpansionType.S5B]);

                if ((state.period != period) || (hasOctave && state.octave != octave) || (instrument != state.instrument) || force)
                {
                    var noteTable = NesApu.GetNoteTableForChannelType(channel.Type, project.PalMode, project.ExpansionNumN163Channels);
                    var note = release ? Note.NoteRelease : (stop ? Note.NoteStop : state.note);
                    var finePitch = 0;

                    if (!stop && !release && state.state != ChannelState.Stopped)
                    {
                        if (channel.Type == ChannelType.Noise)
                            note = (period ^ 0x0f) + 32;
                        else
                            note = (byte)GetBestMatchingNote(period, noteTable, out finePitch);

                        if (hasOctave)
                        {
                            period *= (1 << octave);
                            while (note > 12)
                            {
                                note -= 12;
                                octave++;
                            }
                            note += octave * 12;
                            note = Math.Min(note, noteTable.Length - 1);
                            finePitch = period - noteTable[note];
                        }
                    }

                    if (note < Note.MusicalNoteMin || note > Note.MusicalNoteMax)
                    {
                        if (note > Note.MusicalNoteMax && note != Note.NoteRelease)
                            note = Note.MusicalNoteMax;
                        instrument = null;
                    }

                    if ((state.note != note) || (state.instrument != instrument && instrument != null) || force)
                    {
                        var pattern = GetOrCreatePattern(channel, p);
                        var newNote = pattern.GetOrCreateNoteAt(n);
                        newNote.Value = (byte)note;
                        newNote.Instrument = instrument;
                        state.note = note;
                        state.octave = octave;
                        if (instrument != null)
                            state.instrument = instrument;
                        if (!attack)
                            newNote.HasAttack = false;
                        hasNote = note != 0;
                    }

                    if (hasPitch && !stop)
                    {
                        Channel.GetShiftsForType(channel.Type, project.ExpansionNumN163Channels, out int pitchShift, out _);

                        // We scale all pitches changes (slides, fine pitch, pitch envelopes) for
                        // some channels with HUGE pitch values (N163, VRC7).
                        finePitch >>= pitchShift;

                        var pitch = (sbyte)Utils.Clamp(finePitch, Note.FinePitchMin, Note.FinePitchMax);

                        if (pitch != state.pitch)
                        {
                            var pattern = GetOrCreatePattern(channel, p).GetOrCreateNoteAt(n).FinePitch = pitch;
                            state.pitch = pitch;
                        }
                    }

                    state.period = period;
                }
            }

            return hasNote;
        }

        public static byte[] Decompress(byte[] compressed_data)
        {
            var outputStream = new MemoryStream();
            using (var compressedStream = new MemoryStream(compressed_data))
            using (System.IO.Compression.GZipStream sr = new System.IO.Compression.GZipStream(
                compressedStream, System.IO.Compression.CompressionMode.Decompress))
            {
                sr.CopyTo(outputStream);
                outputStream.Position = 0;
                return outputStream.ToArray();
            }
        }

        public Project Load(string filename, int patternLength, int frameSkip, bool adjustClock, bool reverseDpcm, bool preserveDpcmPad, bool ym2149AsEpsm)
        {
            var vgmFile = System.IO.File.ReadAllBytes(filename);
            if (filename.EndsWith(".vgz"))
                vgmFile = Decompress(vgmFile);

            if (!vgmFile.Skip(0).Take(4).SequenceEqual(Encoding.ASCII.GetBytes("Vgm ")))
            {
                Log.LogMessage(LogSeverity.Error, "Incompatible file.");
                return null;
            }
            /*if (!vgmFile.Skip(8).Take(4).SequenceEqual(BitConverter.GetBytes(0x00000170)))
            {  
                Log.LogMessage(LogSeverity.Error, "Not version 1.70");
                return null;
            }*/

            preserveDpcmPadding = preserveDpcmPad;
            Array.Fill(clockMultiplier, 1);
            bool pal = false;
            project = new Project();
            project.Name = "VGM Import";
            project.Author = "unknown";
            project.Copyright = "";
            project.PalMode = false;
            var songName = "VGM Import";
            project.SetExpansionAudioMask(0xff, 0);
            song = project.CreateSong(songName);
            song.SetDefaultPatternLength(patternLength);
            var p = 0;
            var n = 0;
            channelStates = new ChannelState[50];
            for (int i = 0; i < song.Channels.Length; i++)
                channelStates[i] = new ChannelState();


            var vgmDataOffset = BitConverter.ToInt32(vgmFile.Skip(0x34).Take(4).ToArray())+0x34;
            //Log.LogMessage(LogSeverity.Info, "VGM Data Startoffset: " + vgmDataOffset);
            var vgmData = vgmFile.Skip(vgmDataOffset).Take(1).ToArray();
            if (adjustClock)
            {
                if (BitConverter.ToInt32(vgmFile.Skip(0x74).Take(4).ToArray()) > 0)
                    clockMultiplier[ExpansionType.S5B] = (float)BitConverter.ToInt32(vgmFile.Skip(0x74).Take(4).ToArray()) / 1789772;
                if (BitConverter.ToInt32(vgmFile.Skip(0x44).Take(4).ToArray()) > 0)
                    clockMultiplier[ExpansionType.EPSM] = 4000000 / (float)BitConverter.ToInt32(vgmFile.Skip(0x44).Take(4).ToArray()) / 4000000;
                if (BitConverter.ToInt32(vgmFile.Skip(0x48).Take(4).ToArray()) > 0)
                    clockMultiplier[ExpansionType.EPSM] = (float)BitConverter.ToInt32(vgmFile.Skip(0x48).Take(4).ToArray()) / 8000000;
                if (BitConverter.ToInt32(vgmFile.Skip(0x4C).Take(4).ToArray()) > 0)
                    clockMultiplier[ExpansionType.EPSM] = (float)BitConverter.ToInt32(vgmFile.Skip(0x4C).Take(4).ToArray()) / 8000000;
                if (BitConverter.ToInt32(vgmFile.Skip(0x2c).Take(4).ToArray()) > 0)
                    clockMultiplier[ExpansionType.EPSM] = (float)BitConverter.ToInt32(vgmFile.Skip(0x2C).Take(4).ToArray()) / 8000000;
                if (BitConverter.ToInt32(vgmFile.Skip(0x10).Take(4).ToArray()) > 0)
                    clockMultiplier[ExpansionType.Vrc7] = (float)BitConverter.ToInt32(vgmFile.Skip(0x10).Take(4).ToArray()) / 3579545;

                if (ym2149AsEpsm)
                {
                    if (BitConverter.ToInt32(vgmFile.Skip(0x74).Take(4).ToArray()) > 0)
                        clockMultiplier[ExpansionType.S5B] = (float)BitConverter.ToInt32(vgmFile.Skip(0x74).Take(4).ToArray()) / 2000000;
                    ym2149AsEPSM = ym2149AsEpsm;
                }
            }
            var chipCommands = 0;
            var unknownChipCommands = 0;
            var samples = 0;
            var frame = 0;
            int expansionMask = 0;
            while (vgmDataOffset < vgmFile.Length) {
                if(expansionMask != project.ExpansionAudioMask)
                    project.SetExpansionAudioMask(expansionMask, 0);
                if (vgmData[0] == 0x67)  //DataBlock
                {
                    Log.LogMessage(LogSeverity.Info, "DataBlock Size: " + Convert.ToHexString(vgmFile.Skip(vgmDataOffset + 3).Take(4).ToArray()));
                    Log.LogMessage(LogSeverity.Info, "DataBlock Type: " + Convert.ToHexString(vgmFile.Skip(vgmDataOffset + 2).Take(1).ToArray()));
                    Log.LogMessage(LogSeverity.Info, "DataBlock Addr: " + Convert.ToHexString(vgmFile.Skip(vgmDataOffset + 3 + 4).Take(2).ToArray()));
                    if (vgmFile.Skip(vgmDataOffset + 2).Take(1).ToArray()[0] == 0xC2)
                    {
                        var data = vgmFile.Skip(vgmDataOffset + 3 + 4 + 2).Take(BitConverter.ToInt32(vgmFile.Skip(vgmDataOffset + 3).Take(4).ToArray()) - 2).ToArray();
                        for (int i = 0; i < data.Length; i++)
                        {
                            dpcmData[i + BitConverter.ToUInt16(vgmFile.Skip(vgmDataOffset + 3 + 4).Take(2).ToArray()) - 0xc000] = data[i];
                        }

                    }
                    else if (vgmFile.Skip(vgmDataOffset + 2).Take(1).ToArray()[0] == 0x07)
                    {
                        pcmRAMData = vgmFile.Skip(vgmDataOffset + 3 + 4 + 2).Take(BitConverter.ToInt32(vgmFile.Skip(vgmDataOffset + 3).Take(4).ToArray()) - 2).ToArray();
                    }
                    else
                        dpcmData = vgmFile.Skip(vgmDataOffset + 3 + 4 + 2).Take(BitConverter.ToInt32(vgmFile.Skip(vgmDataOffset + 3).Take(4).ToArray()) - 2).ToArray();
                    vgmDataOffset = vgmDataOffset + BitConverter.ToInt32(vgmFile.Skip(vgmDataOffset + 3).Take(4).ToArray()) + 3 + 4;
                }
                if (vgmData[0] == 0x68)  //DataBlock
                {
                    var readOffset = vgmFile.Skip(vgmDataOffset + 3).Take(3).ToArray();
                    var writeOffset = vgmFile.Skip(vgmDataOffset + 3 + 3).Take(3).ToArray();
                    var copySize = vgmFile.Skip(vgmDataOffset + 3 + 3 + 3).Take(3).ToArray();
                    Log.LogMessage(LogSeverity.Info, "PCM RAM Copy Read Offset: " + Convert.ToHexString(readOffset));
                    Log.LogMessage(LogSeverity.Info, "PCM RAM Copy Write Offset: " + Convert.ToHexString(writeOffset));
                    Log.LogMessage(LogSeverity.Info, "PCM RAM Copy: " + Convert.ToHexString(vgmFile.Skip(vgmDataOffset + 2).Take(1).ToArray()));
                    Log.LogMessage(LogSeverity.Info, "PCM RAM COPY Size: " + Convert.ToHexString(copySize));
                    if (vgmFile.Skip(vgmDataOffset + 2).Take(1).ToArray()[0] == 0x07)
                    {
                        var data = pcmRAMData.Skip(Utils.Bytes24BitToInt(readOffset)).Take(Utils.Bytes24BitToInt(copySize)).ToArray();
                        for (int i = 0; i < data.Length; i++)
                        {
                            dpcmData[i + Utils.Bytes24BitToInt(writeOffset) - 0xc000] = data[i];
                        }

                    }
                    vgmDataOffset = vgmDataOffset + 12;
                }
                else if (vgmData[0] == 0x66)
                {
                    vgmDataOffset = vgmDataOffset + 1;
                    //Log.LogMessage(LogSeverity.Info, "VGM Data End");
                    break;
                }

                else if (vgmData[0] == 0x61 || vgmData[0] == 0x63 || vgmData[0] == 0x62 || (vgmData[0] >= 0x70 && vgmData[0] <= 0x8f))
                {
                    if (vgmData[0] == 0x63)
                    {
                        vgmDataOffset = vgmDataOffset + 1;
                        samples = samples + 882;
                        pal = true;
                    }
                    else if (vgmData[0] == 0x62)
                    {
                        vgmDataOffset = vgmDataOffset + 1;
                        samples = samples + 735;
                    }
                    else if (vgmData[0] == 0x61)
                    {
                        samples = samples + BitConverter.ToInt16(vgmFile.Skip(vgmDataOffset + 1).Take(2).ToArray());
                        vgmDataOffset = vgmDataOffset + 3;
                    }
                    else if (vgmData[0] >= 0x80)
                    {
                        samples = samples + vgmData[0] - 0x80;
                    }
                    else
                    {
                        samples = samples + vgmData[0] - 0x6F;
                        vgmDataOffset = vgmDataOffset + 1;
                    }
                    while (samples >= 735)
                    {
                        p = (frame - frameSkip) / song.PatternLength;
                        n = (frame - frameSkip) % song.PatternLength;
                        song.SetLength(p + 1);
                        frame++;
                        samples = samples - 735;
                        if (frameSkip < frame)
                            for (int c = 0; c < song.Channels.Length; c++)
                                UpdateChannel(p, n, song.Channels[c], channelStates[c]);
                    }
                }
                else if (vgmData[0] == 0x4F || vgmData[0] == 0x50 || vgmData[0] == 0x31)
                    vgmDataOffset = vgmDataOffset + 2;
                else if (vgmData[0] >= 0xC0 && vgmData[0] <= 0xDF)
                    vgmDataOffset = vgmDataOffset + 4;
                else if (vgmData[0] == 0xE0)
                    vgmDataOffset = vgmDataOffset + 5;
                else if (vgmData[0] >= 0x90 && vgmData[0] <= 0x92)
                    vgmDataOffset = vgmDataOffset + 6;
                else if (vgmData[0] == 0x93)
                    vgmDataOffset = vgmDataOffset + 11;
                else if (vgmData[0] == 0x94)
                    vgmDataOffset = vgmDataOffset + 2;
                else if (vgmData[0] == 0x95)
                    vgmDataOffset = vgmDataOffset + 5;
                else
                {

                    vgmData = vgmFile.Skip(vgmDataOffset).Take(3).ToArray();
                    if (vgmData[0] == 0xB4)
                    {

                        if (vgmData[1] == 0x17 && vgmData[2] == 0xc0)
                        {
                            if (apuRegister[1] == 0x87 && apuRegister[2] == 0xff)
                                apuRegister[0x03]++;
                            if (apuRegister[1] == 0x8f && apuRegister[2] == 0x00)
                                apuRegister[0x03]--;
                            if (apuRegister[5] == 0x87 && apuRegister[6] == 0xff)
                                apuRegister[0x07]++;
                            if (apuRegister[5] == 0x8f && apuRegister[6] == 0x00)
                                apuRegister[0x07]--;
                        }

                            if (vgmData[1] == 0x15 && (vgmData[2] & 0x10) > 0)
                            dpcmTrigger = true;
                        apuRegister[vgmData[1]] = vgmData[2];
                    }
                    else if (vgmData[0] == 0x51)
                    {
                        if (vgmData[1] >= 0x20 && vgmData[1] <= 0x28)
                        {
                            int channel = vgmData[1] - 0x20;
                            if ((vgmData[2] & 0x10) > 0)
                                if(channel < 6)
                                    vrc7Trigger[channel] = 1;
                        }
                        vrc7Register[vgmData[1]] = vgmData[2];
                        expansionMask = expansionMask | ExpansionType.Vrc7Mask;
                    }
                    else if (vgmData[0] == 0x56 || vgmData[0] == 0x52 || vgmData[0] == 0x58 || vgmData[0] == 0x55)
                    {
                        if(vgmData[1] == 0x10)
                            epsmRegisterLo[vgmData[1]] = epsmRegisterLo[vgmData[1]] | vgmData[2];
                        else if (vgmData[1] == 0x28)
                        {
                            int channel = ((((vgmData[2] & 4) >> 2) + 1) * ((vgmData[2] & 3)+1)) -1;
                            if ((vgmData[2] & 0x7) == 0)
                            {
                                if ((vgmData[2] & 0xf0) > 0 && epsmFmEnabled[0] == 0)
                                {
                                    epsmFmTrigger[0] = 1;
                                    epsmFmKey[0] = vgmData[2];
                                }
                                epsmFmEnabled[0] = (vgmData[2] & 0xf0) > 0 ? 1 : 0;
                            }
                            if ((vgmData[2] & 0x7) == 1)
                            {
                                if ((vgmData[2] & 0xf0) > 0 && epsmFmEnabled[1] == 0)
                                {
                                    epsmFmTrigger[1] = 1;
                                    epsmFmKey[1] = vgmData[2];
                                }
                                epsmFmEnabled[1] = (vgmData[2] & 0xf0) > 0 ? 1 : 0;
                            }
                            if ((vgmData[2] & 0x7) == 2)
                            {
                                if ((vgmData[2] & 0xf0) > 0 && epsmFmEnabled[2] == 0)
                                {
                                    epsmFmTrigger[2] = 1;
                                    epsmFmKey[2] = vgmData[2];
                                }
                                epsmFmEnabled[2] = (vgmData[2] & 0xf0) > 0 ? 1 : 0;
                            }
                            if ((vgmData[2] & 0x7) == 4)
                            {
                                if ((vgmData[2] & 0xf0) > 0 && epsmFmEnabled[3] == 0)
                                {
                                    epsmFmTrigger[3] = 1;
                                    epsmFmKey[3] = vgmData[2];
                                }
                                epsmFmEnabled[3] = (vgmData[2] & 0xf0) > 0 ? 1 : 0;
                            }
                            if ((vgmData[2] & 0x7) == 5)
                            {
                                if ((vgmData[2] & 0xf0) > 0 && epsmFmEnabled[4] == 0)
                                {
                                    epsmFmTrigger[4] = 1;
                                    epsmFmKey[4] = vgmData[2];
                                }
                                epsmFmEnabled[4] = (vgmData[2] & 0xf0) > 0 ? 1 : 0;
                            }
                            if ((vgmData[2] & 0x7) == 6)
                            {
                                if ((vgmData[2] & 0xf0) > 0 && epsmFmEnabled[5] == 0)
                                {
                                    epsmFmTrigger[5] = 1;
                                    epsmFmKey[5] = vgmData[2];
                                }
                                epsmFmEnabled[5] = (vgmData[2] & 0xf0) > 0 ? 1 : 0;
                            }
                        }
                        else if (vgmData[1] >= 0x30 && vgmData[1] <= 0x4F)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0x7f;
                        else if (vgmData[1] >= 0x50 && vgmData[1] <= 0x5F)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0xdf;
                        else if (vgmData[1] >= 0x60 && vgmData[1] <= 0x6F)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0x9f;
                        else if (vgmData[1] >= 0x70 && vgmData[1] <= 0x7F)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0x1f;
                        else if (vgmData[1] >= 0x90 && vgmData[1] <= 0x9F)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0x0f;
                        else if (vgmData[1] >= 0xB0 && vgmData[1] <= 0xB2)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0x3f;
                        else if (vgmData[1] >= 0xB4 && vgmData[1] <= 0xB6)
                            epsmRegisterLo[vgmData[1]] = vgmData[2] & 0xf7;
                        else
                            epsmRegisterLo[vgmData[1]] = vgmData[2];
                        expansionMask = expansionMask | ExpansionType.EPSMMask;
                    }
                    else if (vgmData[0] == 0x57 || vgmData[0] == 0x53 || vgmData[0] == 0x59)
                    {
                        if (vgmData[1] >= 0x30 && vgmData[1] <= 0x4F)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0x7f;
                        else if (vgmData[1] >= 0x50 && vgmData[1] <= 0x5F)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0xdf;
                        else if (vgmData[1] >= 0x60 && vgmData[1] <= 0x6F)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0x9f;
                        else if (vgmData[1] >= 0x70 && vgmData[1] <= 0x7F)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0x1f;
                        else if (vgmData[1] >= 0x90 && vgmData[1] <= 0x9F)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0x0f;
                        else if (vgmData[1] >= 0xB0 && vgmData[1] <= 0xB2)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0x3f;
                        else if (vgmData[1] >= 0xB4 && vgmData[1] <= 0xB6)
                            epsmRegisterHi[vgmData[1]] = vgmData[2] & 0xf7;
                        else
                            epsmRegisterHi[vgmData[1]] = vgmData[2];
                        expansionMask = expansionMask | ExpansionType.EPSMMask;
                    }
                    else if (vgmData[0] == 0xA0)
                    {
                        if (ym2149AsEpsm)
                        {
                            epsmRegisterLo[vgmData[1]] = vgmData[2];
                            expansionMask = expansionMask | ExpansionType.EPSMMask;
                        }
                        else
                        {
                            s5bRegister[vgmData[1]] = vgmData[2];
                            expansionMask = expansionMask | ExpansionType.S5BMask;
                        }
                    }
                    else
                    {
                        if(unknownChipCommands > 100)
                        Log.LogMessage(LogSeverity.Info, "Unknown VGM Chip Data: " + Convert.ToHexString(vgmData) + " offset: " + vgmDataOffset);
                        unknownChipCommands++;
                    }
                    //Log.LogMessage(LogSeverity.Info, "VGM Chip Data: " + Convert.ToHexString(vgmData));
                    chipCommands++;
                    vgmDataOffset = vgmDataOffset + 3;
                }
                vgmData = vgmFile.Skip(vgmDataOffset).Take(1).ToArray();
            }
            if(pal)
                Log.LogMessage(LogSeverity.Info, "VGM is PAL");
            else
                Log.LogMessage(LogSeverity.Info, "VGM is NTSC");
            Log.LogMessage(LogSeverity.Info, "VGM Chip Commands: " + chipCommands);
            Log.LogMessage(LogSeverity.Info, "S5b Clock Multiplier: " + clockMultiplier[ExpansionType.S5B]);
            Log.LogMessage(LogSeverity.Info, "EPSM Clock Multiplier: " + clockMultiplier[ExpansionType.EPSM]);
            Log.LogMessage(LogSeverity.Info, "VRC7 Clock Multiplier: " + clockMultiplier[ExpansionType.Vrc7]);
            Log.LogMessage(LogSeverity.Info, "Frames: " + frame + " time: " + (frame/60) + "s");

            if (vgmFile.Skip(vgmDataOffset).Take(4).SequenceEqual(Encoding.ASCII.GetBytes("Gd3 ")))
            {
                vgmDataOffset = vgmDataOffset + 4+4+4; // "Gd3 " + version + gd3 length data
                var gd3Data = vgmFile.Skip(vgmDataOffset).Take(vgmFile.Length-vgmDataOffset).ToArray();
                var gd3DataArray = System.Text.Encoding.Unicode.GetString(gd3Data).Split("\0");
                Log.LogMessage(LogSeverity.Info, "Gd3 Data: " + System.Text.Encoding.Unicode.GetString(gd3Data));
                Log.LogMessage(LogSeverity.Info, "Track Name: " + gd3DataArray[0]);
                songName = gd3DataArray[0];
                Log.LogMessage(LogSeverity.Info, "Game Name: " + gd3DataArray[2]);
                project.Name = gd3DataArray[2] + gd3DataArray[4];
                Log.LogMessage(LogSeverity.Info, "System Name: " + gd3DataArray[4]);
                Log.LogMessage(LogSeverity.Info, "Original Author Name: " + gd3DataArray[6]);
                project.Copyright = gd3DataArray[6];
                Log.LogMessage(LogSeverity.Info, "Release Date: " + gd3DataArray[7]);
                Log.LogMessage(LogSeverity.Info, "Converted by: " + gd3DataArray[8]);
                project.Author = gd3DataArray[8];
                Log.LogMessage(LogSeverity.Info, "Notes: " + gd3DataArray[9]);
            }


            frame++;
            p = (frame - frameSkip) / song.PatternLength;
            n = (frame - frameSkip) % song.PatternLength;
            for (int c = 0; c < song.Channels.Length; c++)
            {
                if (channelStates[c].state != ChannelState.Stopped)
                GetOrCreatePattern(song.Channels[c], p).GetOrCreateNoteAt(n).IsStop = true;
            }
            song.Name = songName;
            song.SetSensibleBeatLength();
            song.ConvertToCompoundNotes();
            song.DeleteEmptyPatterns();
            song.UpdatePatternStartNotes();
            song.InvalidateCumulativePatternCache();
            project.DeleteUnusedInstruments();
            foreach (var sample in project.Samples)
                sample.ReverseBits = reverseDpcm;
            return project;
        }
    }


}
