import React from 'react';
import AppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import { Link as RouterLink } from 'react-router-dom';
import Link, {LinkProps} from '@mui/material/Link';
import styled from '@emotion/styled'

const Header: React.FC = () => {
    return (
        <StyledAppBar position="static" sx={{ width: '100%' }} >
            <Toolbar>
                <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                    My Web3 App
                </Typography>
                <StyledLink component={RouterLink} to="/" color="inherit" underline="none" sx={{ marginRight: 2 }}>
                    Home
                </StyledLink>
                <StyledLink component={RouterLink} to="/issue" color="inherit" underline="none" sx={{ marginRight: 2 }}>
                    Issue
                </StyledLink>
                <StyledLink component={RouterLink} to="/hacker-info" color="inherit" underline="none">
                    Hacker info
                </StyledLink>
            </Toolbar>
        </StyledAppBar>
    );
};


const StyledAppBar = styled(AppBar)`
    background-color: transparent;
    z-index: 5;
    background-image: none;
    mix-blend-mode: difference;
    border-bottom: 1px solid white;
`;

const StyledLink = styled(Link)<LinkProps & { component: React.ElementType, to?: string }>`
    color: white;
    text-transform: uppercase;
`;

export default Header;

