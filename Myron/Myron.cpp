//
//  Myron.cpp
//  Myron
//
//  Created by Jeffrey Drake on 11-12-31.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#include "Myron.h"

namespace Myron
{
    namespace Keys {
        constexpr uint32_t Fn(uint32_t n)
        {
            return (function_key << 8) | n;
        }
    }
}
