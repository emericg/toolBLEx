/*!
 * Copyright (c) 2018 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef UTILS_VERSIONCHECKER_H
#define UTILS_VERSIONCHECKER_H
/* ************************************************************************** */

#include <cstdio>
#include <QString>

struct VersionChecker
{
    int major = 0, minor = 0, revision = 0, build = 0;

    VersionChecker(const QString &version_qstr)
    {
        sscanf(version_qstr.toLatin1().constData(), "%d.%d.%d.%d",
               &major, &minor, &revision, &build);
    }

    bool operator == (const VersionChecker &other)
    {
        return (major == other.major
                && minor == other.minor
                && revision == other.revision
                && build == other.build);
    }
    bool operator < (const VersionChecker &other)
    {
        if (major < other.major)
            return true;
        if (major > other.major)
            return false;
        if (minor < other.minor)
            return true;
        if (minor > other.minor)
            return false;
        if (revision < other.revision)
            return true;
        if (revision > other.revision)
            return false;
        if (build < other.build)
            return true;
        if (build > other.build)
            return false;

        return false;
    }
    bool operator <= (const VersionChecker &other)
    {
        if (*this < other || *this == other)
            return true;

        return false;
    }
    bool operator >= (const VersionChecker &other)
    {
        if (*this > other || *this == other)
            return true;

        return false;
    }
    bool operator > (const VersionChecker &other)
    {
        if (!(*this == other) && !(*this < other))
            return true;

        return false;
    }
};

/* ************************************************************************** */
/*
static void testUtilsVersionStringComparison()
{
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("3.7.8.0") )   == true);
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("3.7.8") )     == true);
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("3.7.8") )     == true);
    assert( (VersionChecker("3.7.0.0")  ==  VersionChecker("3.7") )       == true);
    assert( (VersionChecker("3.0.0.0")  ==  VersionChecker("3") )         == true);
    assert( (VersionChecker("3")        ==  VersionChecker("3.0.0.0") )   == true);
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("3.7") )       == false);
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("3.6.8") )     == false);
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("5") )         == false);
    assert( (VersionChecker("3.7.8.0")  ==  VersionChecker("2.7.8") )     == false);
    assert( (VersionChecker("01.02.03") ==  VersionChecker("01.02.03") )  == true);
    assert( (VersionChecker("01.02.03") ==  VersionChecker("02.02.03") )  == false);

    assert( (VersionChecker("3")         <  VersionChecker("3.7.9") )     == true);
    assert( (VersionChecker("1.7.9")     <  VersionChecker("3.1") )       == true);
    assert( (VersionChecker("3.7.8.0")   <  VersionChecker("3.7.8") )     == false);
    assert( (VersionChecker("3.7.9")     <  VersionChecker("3.7.8") )     == false);
    assert( (VersionChecker("3.7.8")     <  VersionChecker("3.7.9") )     == true);
    assert( (VersionChecker("3.7")       <  VersionChecker("3.7.0") )     == false);
    assert( (VersionChecker("3.7.8.0")   <  VersionChecker("3.7.8") )     == false);
    assert( (VersionChecker("2.7.9")     <  VersionChecker("3.8.8") )     == true);
    assert( (VersionChecker("3.7.9")     <  VersionChecker("3.8.8") )     == true);
    assert( (VersionChecker("4")         <  VersionChecker("3.7.9") )     == false);
    assert( (VersionChecker("01.02.03")  <  VersionChecker("01.02.03") )  == false);
    assert( (VersionChecker("01.02.03")  <  VersionChecker("02.02.03") )  == true);

    assert( (VersionChecker("4")         >  VersionChecker("3.7.9") )     == true);
    assert( (VersionChecker("3.7.9")     >  VersionChecker("3.7.8") )     == true);
    assert( (VersionChecker("4.7.9")     >  VersionChecker("3.1") )       == true);
    assert( (VersionChecker("3.10")      >  VersionChecker("3.8.8") )     == true);
    assert( (VersionChecker("3.7")       >  VersionChecker("3.7.0") )     == false);
    assert( (VersionChecker("3.7.8.0")   >  VersionChecker("3.7.8") )     == false);
    assert( (VersionChecker("2.7.9")     >  VersionChecker("3.8.8") )     == false);
    assert( (VersionChecker("3.7.9")     >  VersionChecker("3.8.8") )     == false);
    assert( (VersionChecker("02.02.03")  >  VersionChecker("01.02.03") )  == true);
    assert( (VersionChecker("01.02.03")  >  VersionChecker("02.02.03") )  == false);
}
*/
/* ************************************************************************** */
#endif // UTILS_VERSIONCHECKER_H
